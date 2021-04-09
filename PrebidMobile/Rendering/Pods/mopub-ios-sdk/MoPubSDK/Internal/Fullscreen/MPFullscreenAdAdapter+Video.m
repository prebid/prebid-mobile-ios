//
//  MPFullscreenAdAdapter+Video.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdAdapter+MPFullscreenAdViewControllerDelegate.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPFullscreenAdAdapter+Reward.h"
#import "MPFullscreenAdAdapter+Video.h"
#import "MPFullscreenAdViewController+Private.h"
#import "MPFullscreenAdViewController+Video.h"
#import "MPHTTPNetworkSession.h"
#import "MPURLRequest.h"
#import "MPVASTConstant.h"
#import "MPVASTMacroProcessor.h"
#import "MPVASTManager.h"

@interface MPFullscreenAdAdapter (MPVideoPlayerDelegate) <MPVideoPlayerDelegate>
@end

#pragma mark -

@implementation MPFullscreenAdAdapter (Video)

// provide a different name to differentiate from `self.videoConfig`
- (MPAdConfiguration *)adConfig {
    return self.configuration;
}

- (void)fetchAndLoadVideoAd {
    void (^errorHandler)(NSError *) = ^(NSError *error) {
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
    };

    [MPVASTManager fetchVASTWithData:self.adConfig.adResponseData completion:^(MPVASTResponse *response, NSError *error) {
        if (error) {
            errorHandler(error);
            return;
        }

        MPVideoConfig *videoConfig = [[MPVideoConfig alloc] initWithVASTResponse:response
                                                              additionalTrackers:self.adConfig.vastVideoTrackers];
        videoConfig.isRewardExpected = self.adConfig.hasValidRewardFromMoPubSDK;
        videoConfig.enableEarlyClickthroughForNonRewardedVideo = self.adConfig.enableEarlyClickthroughForNonRewardedVideo;

        if (videoConfig == nil || videoConfig.mediaFiles == nil) {
            errorHandler([NSError errorWithDomain:kMPVASTErrorDomain
                                             code:MPVASTErrorUnableToFindLinearAdOrMediaFileFromURI
                                         userInfo:nil]);
            return;
        }

        self.videoConfig = videoConfig;
        CGSize windowSize = [UIApplication sharedApplication].keyWindow.bounds.size;
        MPVASTMediaFile *remoteMediaFile = [MPVASTMediaFile bestMediaFileFromCandidates:videoConfig.mediaFiles
                                                                       forContainerSize:windowSize
                                                                   containerScaleFactor:[UIScreen mainScreen].scale];
        if (remoteMediaFile == nil || remoteMediaFile.URL == nil) {
            errorHandler([NSError errorWithDomain:kMPVASTErrorDomain
                                             code:MPVASTErrorUnableToFindLinearAdOrMediaFileFromURI
                                         userInfo:nil]);
            return;
        }

        self.remoteMediaFileToPlay = remoteMediaFile;
        self.vastTracking = [[MPVASTTracking alloc] initWithVideoConfig:videoConfig
                                                               videoURL:remoteMediaFile.URL];
        NSURL *cacheFileURL = [self.mediaFileCache cachedFileURLForRemoteFileURL:remoteMediaFile.URL];

        void (^loadVideo)(void) = ^() {
            self.viewController = [[MPFullscreenAdViewController alloc]  initWithVideoURL:cacheFileURL
                                                                              videoConfig:videoConfig];
            self.viewController.appearanceDelegate = self;
            self.viewController.videoPlayerDelegate = self;
            self.viewController.countdownTimerDelegate = self;
            if (self.isRewardExpected) {
                [self.viewController setRewardCountdownDuration:self.rewardCountdownDuration];
            }

            // Initialize the Viewability tracker now there is a view hierarchy
            // for it to track, and the video is about to load.
            // The Viewability session is okay to start immediately since there is
            // no web view involved.
            self.viewabilityTracker = [self viewabilityTrackerForVideoConfig:self.videoConfig
                                                    containedInContainerView:self.viewController.adContainerView
                                                             adConfiguration:self.configuration];
            [self.viewabilityTracker startTracking];

            // Now that the viewability tracker is ready, set the weak reference to it
            // in the `VASTTracking` object, so it can track the VAST media events.
            self.vastTracking.viewabilityTracker = self.viewabilityTracker;

            [self.viewController loadVideo];
        };

        // `MPVideoPlayerViewController.init` automatically loads the video and triggers delegate callback
        if ([self.mediaFileCache isRemoteFileCached:remoteMediaFile.URL]) {
            [self.mediaFileCache touchCachedFileForRemoteFile:remoteMediaFile.URL]; // for LRU
            loadVideo();
        } else {
            MPURLRequest *request = [MPURLRequest requestWithURL:remoteMediaFile.URL];
            [MPHTTPNetworkSession startTaskWithHttpRequest:request responseHandler:^(NSData * _Nonnull data, NSHTTPURLResponse * _Nonnull response) {
                [self.mediaFileCache storeData:data forRemoteSourceFileURL:remoteMediaFile.URL];
                dispatch_async(dispatch_get_main_queue(), loadVideo);
            } errorHandler:errorHandler];
        }
    }];
}

- (void)dismissPlayerViewController {
    [self.viewController dismiss];
    self.viewController = nil;
}

@end

#pragma mark -

@implementation MPFullscreenAdAdapter (MPAdDestinationDisplayAgentDelegate)

- (void)displayAgentDidDismissModal {
    [self.viewController enableAppLifeCycleEventObservationForAutoPlayPause];
    [self.viewController playVideo]; // continue playing after click-through
}

- (void)displayAgentWillLeaveApplication {
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)displayAgentWillPresentModal {
    [self.viewController pauseVideo];
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self.viewController;
}

@end

#pragma mark -

@implementation MPFullscreenAdAdapter (MPVideoPlayerDelegate)

- (UIViewController *)viewControllerForPresentingModalMRAIDExpandedView {
    return self.viewController;
}

- (void)videoPlayerDidLoadVideo:(id<MPVideoPlayer>)videoPlayer {
    self.hasAdAvailable = YES;
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)videoPlayerDidFailToLoadVideo:(id<MPVideoPlayer>)videoPlayer error:(NSError *)error {
    self.hasAdAvailable = NO;
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)videoPlayerDidStartVideo:(id<MPVideoPlayer>)videoPlayer duration:(NSTimeInterval)duration {
    // We only support one creative in one ad response, so we trigger all of Start, Impression and
    // CreativeView events at the same time. Ad level impression tracking happens automatically by
    // `handleAdEvent:MPFullscreenAdEventDidAppear`, and here only needs to take care of VAST
    // impression tracking.
    [self.vastTracking handleVideoEvent:MPVideoEventStart videoTimeOffset:0];
    [self.vastTracking handleVideoEvent:MPVideoEventCreativeView videoTimeOffset:0];
    [self.vastTracking handleVideoEvent:MPVideoEventImpression videoTimeOffset:0];
}

- (void)videoPlayerDidCompleteVideo:(id<MPVideoPlayer>)videoPlayer duration:(NSTimeInterval)duration {
    [self.vastTracking handleVideoEvent:MPVideoEventComplete videoTimeOffset:duration];

    // Note: Do not hold back the reward if `isRewardExpected` is NO, because it's possible that
    // the rewarded is not defined in the ad response / ad configuration, but is defined after
    // the reward condition has been satisfied (for 3rd party ad SDK's).
    if (self.configuration.selectedReward != nil) {
        [self.delegate fullscreenAdAdapter:self willRewardUser:self.configuration.selectedReward];
    }
}

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
videoDidReachProgressTime:(NSTimeInterval)videoProgress
           duration:(NSTimeInterval)duration {
    [self.vastTracking handleVideoProgressEvent:videoProgress videoDuration:duration];
}

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
    didTriggerEvent:(MPVideoPlayerEvent)event
      videoProgress:(NSTimeInterval)videoProgress {
    switch (event) {
        case MPVideoPlayerEvent_ClickThrough: {
            [self.adDestinationDisplayAgent displayDestinationForURL:self.videoConfig.clickThroughURL skAdNetworkClickthroughData:self.configuration.skAdNetworkClickthroughData];

            // need to take care of both VAST level and ad level click tracking
            [self.vastTracking handleVideoEvent:MPVideoEventClick videoTimeOffset:videoProgress];

            // ad level click tracking
            // Note: Do not call `[self.vastTracking uniquelySendURLs:self.adConfig.clickTrackingURLs]`
            // because the ad level click trackers are sent by `handleAdEvent:MPFullscreenAdEventDidReceiveTap`.
            [self.delegate fullscreenAdAdapterDidReceiveTap:self];
            break;
        }
        case MPVideoPlayerEvent_Close: {
            // Typically the creative only has one of the "close" tracker and the "closeLinear"
            // tracker. If it has both trackers, we send both as it asks for.
            [self.vastTracking handleVideoEvent:MPVideoEventClose videoTimeOffset:videoProgress];
            [self.vastTracking handleVideoEvent:MPVideoEventCloseLinear videoTimeOffset:videoProgress];
            [self dismissPlayerViewController];
            break;
        }
        case MPVideoPlayerEvent_Pause: {
            // Forward the event to the VAST tracker
            [self.vastTracking handleVideoEvent:MPVideoEventPause videoTimeOffset:videoProgress];
            break;
        }
        case MPVideoPlayerEvent_Resume: {
            // Forward the event to the VAST tracker
            [self.vastTracking handleVideoEvent:MPVideoEventResume videoTimeOffset:videoProgress];
            break;
        }
        case MPVideoPlayerEvent_Skip: {
            // Skipping the video should stop playback.
            // This is required since the Viewability tracker may hold onto the `videoPlayer`
            // reference after the fullscreen has dismissed (causing the audio playback of the
            // video player to continue).
            [videoPlayer stopVideo];

            // Typically the creative only has one of the "close" tracker and the "closeLinear"
            // tracker. If it has both trackers, we send both as it asks for.
            [self.vastTracking handleVideoEvent:MPVideoEventSkip videoTimeOffset:videoProgress];
            [self.vastTracking handleVideoEvent:MPVideoEventClose videoTimeOffset:videoProgress];
            [self.vastTracking handleVideoEvent:MPVideoEventCloseLinear videoTimeOffset:videoProgress];
            [self dismissPlayerViewController];
            break;
        }
    }
}

#pragma mark - industry icon view

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
didShowIndustryIconView:(MPVASTIndustryIconView *)iconView {
    [self.vastTracking uniquelySendURLs:iconView.icon.viewTrackingURLs];
}

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayerView
didClickIndustryIconView:(MPVASTIndustryIconView *)iconView
overridingClickThroughURL:(NSURL * _Nullable)url {
    // Since this is the privacy icon, send @c nil for skAdNetworkClickthroughData
    if (url.absoluteString.length > 0) {
        [self.adDestinationDisplayAgent displayDestinationForURL:url skAdNetworkClickthroughData:nil];
    } else {
        [self.adDestinationDisplayAgent displayDestinationForURL:iconView.icon.clickThroughURL skAdNetworkClickthroughData:nil];
    }

    [self.viewController disableAppLifeCycleEventObservationForAutoPlayPause];
    [self.vastTracking uniquelySendURLs:iconView.icon.clickTrackingURLs];

    // ad level click tracking
    // Note: Do not call `[self.vastTracking uniquelySendURLs:self.adConfig.clickTrackingURLs]`
    // because the ad level click trackers are sent by `handleAdEvent:MPFullscreenAdEventDidReceiveTap`.
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
}

#pragma mark - companion ad view

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
didShowCompanionAdView:(MPVASTCompanionAdView *)companionAdView {
    // Aggregate trackers
    NSMutableSet<NSURL *> *urls = [NSMutableSet new];
    for (MPVASTTrackingEvent *event in companionAdView.ad.creativeViewTrackers) {
        [urls addObject:event.URL];
    }

    // Additional trackers
    NSArray<MPVASTTrackingEvent *> *additionalTrackingUrls = self.adConfig.vastVideoTrackers[MPVideoEventCompanionAdView];
    [additionalTrackingUrls enumerateObjectsUsingBlock:^(MPVASTTrackingEvent * _Nonnull event, NSUInteger idx, BOOL * _Nonnull stop) {
        [urls addObject:event.URL];
    }];

    [self.vastTracking uniquelySendURLs:urls.allObjects];
}

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
didClickCompanionAdView:(MPVASTCompanionAdView *)companionAdView
overridingClickThroughURL:(NSURL * _Nullable)url {
    // Navigation to destination. Priority is given to the override clickthrough URL.
    // Otherwise the clickthrough URL specified in the companion ad will be used.
    NSURL *clickthroughDestinationUrl = url ?: companionAdView.ad.clickThroughURL;

    // In the event that there is no clickthrough, do not continue.
    if (clickthroughDestinationUrl == nil) {
        return;
    }

    // Begin navigating to the clickthrough destination.
    [self.adDestinationDisplayAgent displayDestinationForURL:clickthroughDestinationUrl skAdNetworkClickthroughData:self.configuration.skAdNetworkClickthroughData];

    [self.viewController disableAppLifeCycleEventObservationForAutoPlayPause];

    // Aggregate trackers with additional trackers
    NSMutableSet<NSURL *> *urls = [NSMutableSet set];
    if (companionAdView.ad.clickTrackingURLs != nil) {
        [urls addObjectsFromArray:companionAdView.ad.clickTrackingURLs];
    }

    NSArray<MPVASTTrackingEvent *> *additionalTrackingUrls = self.adConfig.vastVideoTrackers[MPVideoEventCompanionAdClick];
    [additionalTrackingUrls enumerateObjectsUsingBlock:^(MPVASTTrackingEvent * _Nonnull event, NSUInteger idx, BOOL * _Nonnull stop) {
        [urls addObject:event.URL];
    }];

    [self.vastTracking uniquelySendURLs:urls.allObjects];

    // ad level click tracking
    // Note: Do not call `[self.vastTracking uniquelySendURLs:self.adConfig.clickTrackingURLs]`
    // because the ad level click trackers are sent by `handleAdEvent:MPFullscreenAdEventDidReceiveTap`.
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
}

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
didFailToLoadCompanionAdView:(MPVASTCompanionAdView *)companionAdView {
    [self.vastTracking handleVASTError:MPVASTErrorGeneralCompanionAdsError
                       videoTimeOffset:kMPVASTMacroProcessorUnknownTimeOffset];
}

- (void)videoPlayer:(id<MPVideoPlayer>)videoPlayer
companionAdViewRequestDismiss:(MPVASTCompanionAdView *)companionAdView {
    [self dismissPlayerViewController];
}

@end
