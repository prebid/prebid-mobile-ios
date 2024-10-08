/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMVideoCreative.h"
#import "PBMAbstractCreative+Protected.h"

#import "PBMFunctions+Private.h"
#import "UIView+PBMExtensions.h"

#import "PBMConstants.h"
#import "PBMCreativeModel.h"
#import "PBMDownloadDataHelper.h"
#import "PBMError.h"
#import "PBMFunctions.h"
#import "PBMOpenMeasurementWrapper.h"
#import "PBMOpenMeasurementSession.h"
#import "PBMModalManager.h"
#import "PBMVideoView.h"
#import "PBMModalState.h"
#import "PBMMacros.h"
#import "PBMTransaction.h"
#import "PBMCreativeResolutionDelegate.h"
#import "PBMInterstitialDisplayProperties.h"
#import "PBMCreativeViewabilityTracker.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Private Extension

@interface PBMVideoCreative ()

@property (nonatomic, strong) PBMVideoView *videoView;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) PBMRewardedConfig *rewardedConfig;

@end

#pragma mark - Implementation

@implementation PBMVideoCreative

#pragma mark - Properties

+ (NSInteger)maxSizeForPreRenderContent {
    // 25 MiB
    return 25 * 1024 * 1024;
}

#pragma mark - PBMAbstractCreative

- (instancetype)initWithCreativeModel:(PBMCreativeModel *)creativeModel
                          transaction:(PBMTransaction *)transaction
                            videoData:(NSData *)data {
    self = [super initWithCreativeModel:creativeModel transaction:transaction];
    if (self) {
        PBMAssert(data);

        self.data = data;
        
        self.videoView = [[PBMVideoView alloc] initWithCreative:self];
        self.videoView.videoViewDelegate = self;
        self.view = self.videoView;
        
        self.rewardedConfig = self.creativeModel.adConfiguration.rewardedConfig;
        self.creativeModel.rewardTime = [self calculateRewardTime];
        self.creativeModel.postRewardTime = [self calculatePostRewardTimeWith:self.creativeModel.rewardTime];
    }
    
    return self;
}

- (void)setupView {
    [super setupView];
    [self showVideoViewWithPreloadedData:self.data];
}

- (void)displayWithRootViewController:(UIViewController *)viewController {
    [super displayWithRootViewController:viewController];
    [self.viewabilityTracker start];
    
    [self.videoView startPlayback];
    [self.videoView PBMAddFillSuperviewConstraints];
}

- (void)showAsInterstitialFromRootViewController:(UIViewController *)uiViewController displayProperties:(PBMInterstitialDisplayProperties *)displayProperties {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        
        if (!self) { return; }
        
        if (self.creativeModel.adConfiguration.videoControlsConfig.isMuted) {
            [self.videoView mute];
        } else {
            [self.videoView unmute];
        }
    });
    
    //Create a copy of the interstitialDisplayProperties and modify the closeDelay to take the video length into account.
    PBMInterstitialDisplayProperties* newDisplayProperties = [self createInterstitialPropertiesForCurrentVideoStateFor:displayProperties];
    [super showAsInterstitialFromRootViewController:uiViewController displayProperties:newDisplayProperties];
}

- (void)onAdDisplayed {
    [super onAdDisplayed];
    [self.viewabilityTracker stop];
    self.viewabilityTracker = NULL;
}

- (void)pause {
    [self.videoView pause];
}

- (void)resume {
    [self.videoView resume];
}

- (void)mute {
    [self.videoView mute];
}

- (void)unmute {
    [self.videoView unmute];
}

- (BOOL)isMuted {
    return self.videoView.isMuted;
}

// Should the concept of "close" or dismiss be moved to PBMAbstractCreative?
- (void)close {
    [self.videoView stopOnCloseButton:PBMTrackingEventCloseLinear];
}

- (BOOL)isPlaybackFinished {
    return self.videoView.isPlaybackFinished;
}

- (void)createOpenMeasurementSession {
    
    if (!NSThread.currentThread.isMainThread) {
        PBMLogError(@"Open Measurement session can only be created on the main thread");
        return;
    }
    
    self.transaction.measurementSession = [self.transaction.measurementWrapper
                                          initializeNativeVideoSession:self.videoView
                                                verificationParameters:self.creativeModel.verificationParameters];
    if (self.transaction.measurementSession) {
        [self.videoView addFriendlyObstructionsToMeasurementSession:self.transaction.measurementSession];
        [self.transaction.measurementSession start];
        if (self.transaction.measurementSession.eventTracker) {
            [self.eventManager registerTracker:self.transaction.measurementSession.eventTracker];
        }
        [self.eventManager trackVideoAdLoaded:[PBMVideoVerificationParameters new]];
    }
}

#pragma mark - PBMVideoViewDelegate

- (void)videoViewCompletedDisplay {
    if ([self.creativeViewDelegate respondsToSelector:@selector(videoCreativeDidComplete:)]) {
        [self.creativeViewDelegate videoCreativeDidComplete:self];
    }
    
    // Companion ad:
    // forward the event to the delegate so that it can display the next creative, if any.
    if (self.creativeModel.hasCompanionAd) {
        [self.creativeViewDelegate creativeDidComplete:self];
        return;
    }
    
    if (self.creativeModel.adConfiguration.presentAsInterstitial) {
        // no companion ads so pass this event to the PBMModalManager
        // and close video automatically
        [self.modalManager creativeDisplayCompleted:self];        
        if (self.dismissInterstitialModalState) {
            self.dismissInterstitialModalState();
        }
    } else {
        [self.creativeViewDelegate creativeDidComplete:self];
    }
}

- (void)videoViewFailedWithError:(NSError *)error {
    [self.creativeResolutionDelegate creativeFailed:error];
}

- (void)videoViewReadyToDisplay {
    [self.creativeResolutionDelegate creativeReady:self];
}

- (void)learnMoreWasClicked {
    [self.creativeViewDelegate creativeWasClicked:self];
    [self.eventManager trackEvent:PBMTrackingEventClick];
    
    NSURL* url = [NSURL URLWithString:self.creativeModel.clickThroughURL];
    
    [self pause];
    @weakify(self);
    [super handleClickthrough:url completionHandler:^(BOOL success) {
        // nop
    } onExit:^{
        @strongify(self);
        if (!self) { return; }
        
        [self resume];
    }];
}

- (void)videoViewCurrentPlayingTime:(NSNumber *)currentPlayingTime {
    // NOTE: Rewarded API only
    // Signal to the application that the user has earned the reward after
    // the certain period of time that the ad is on the screen.
    if (!self.creativeModel.adConfiguration.isRewarded) {
        return;
    }
    
    // NOTE: This logic apllicable only to the creatives without endcard.
    if (self.creativeModel.hasCompanionAd) {
        return;
    }
    
    // Try track reward event
    if (!self.creativeModel.userHasEarnedReward &&
        [self.creativeModel.rewardTime doubleValue] >= 0 &&
        [currentPlayingTime doubleValue] >= [self.creativeModel.rewardTime doubleValue]) {
        
        self.creativeModel.userHasEarnedReward = YES;
        [self.creativeViewDelegate creativeDidSendRewardedEvent:self];
        
        // The SDK shows the Learn More button only when the reward clause is met.
        self.videoView.showLearnMore = YES;
        [self.videoView updateLearnMoreButton];
    }
    
    // Try track post-reward event
    if(!self.creativeModel.userPostRewardEventSent &&
       [self.creativeModel.postRewardTime doubleValue] >= 0 &&
       [currentPlayingTime doubleValue] >= [self.creativeModel.postRewardTime doubleValue]) {
        
        self.creativeModel.userPostRewardEventSent = YES;
        [self.modalManager creativeDisplayCompleted:self];
    }
}

- (void)videoViewWasTapped {
    if (self.creativeModel.adConfiguration.clickHandlerOverride != nil) {
        [self.eventManager trackEvent:PBMTrackingEventClick];
        [self pause];
        self.creativeModel.adConfiguration.clickHandlerOverride(^{
            [self resume];
        });
        return;
    }
    
    // Do not process the click if video is finished
    if (self.isPlaybackFinished) {
        return;
    }
    
    [self.creativeViewDelegate creativeViewWasClicked:self];
}

#pragma mark - PBMModalManagerDelegate

- (void)modalManagerDidFinishPop:(PBMModalState*)state {
    
    //Clickthrough
    if (self.clickthroughVisible) {
        [self.creativeViewDelegate creativeClickthroughDidClose:self];
        self.clickthroughVisible = NO;
        return;
    }
    
    if (self.creativeModel.adConfiguration.isBuiltInVideo) {
        [self.creativeViewDelegate creativeFullScreenDidFinish:self];
        return;
    }

    [self close];
    
    //Creative presented as Interstitial
    [self.creativeViewDelegate creativeDidComplete:self];
    [self.creativeViewDelegate creativeInterstitialDidClose:self];
}

- (void)modalManagerDidLeaveApp:(PBMModalState*)state {
    [self.creativeViewDelegate creativeInterstitialDidLeaveApp:self];
}

#pragma mark - Internal methods

- (void)showVideoViewWithPreloadedData:(NSData *)preloadedData {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        if (!self) { return; }
        
        [self.videoView showMediaFileURL:[NSURL URLWithString:self.creativeModel.videoFileURL] preloadedData:preloadedData];
    });
}

#pragma mark - Utility

- (PBMInterstitialDisplayProperties *)createInterstitialPropertiesForCurrentVideoStateFor:(PBMInterstitialDisplayProperties *)initialProperties {
    PBMInterstitialDisplayProperties *newDisplayProperties = [initialProperties copy];
    newDisplayProperties.closeDelay = [self calculateCloseDelayForPubCloseDelay:newDisplayProperties.closeDelay];
    newDisplayProperties.closeDelayLeft = newDisplayProperties.closeDelay;
    return newDisplayProperties;
}

// TODO: - Clarify the requirements and fix calculation logic
- (NSTimeInterval)calculateCloseDelayForPubCloseDelay:(NSTimeInterval)pubCloseDelay {
    if (self.creativeModel.hasCompanionAd) {
        return [self.creativeModel.displayDurationInSeconds doubleValue];
    } else if (self.creativeModel.adConfiguration.videoControlsConfig.skipDelay && self.creativeModel.adConfiguration.videoControlsConfig.skipDelay <= self.creativeModel.displayDurationInSeconds.doubleValue) {
        return self.creativeModel.adConfiguration.videoControlsConfig.skipDelay;
    } else if (self.creativeModel.skipOffset && self.creativeModel.skipOffset.doubleValue <= self.creativeModel.displayDurationInSeconds.doubleValue) {
        return [self.creativeModel.skipOffset doubleValue];
    } else {
        const double videoDuration = self.creativeModel.displayDurationInSeconds.doubleValue;
        if (videoDuration <= 0) {
            return PBMTimeInterval.CLOSE_DELAY_MIN;
        }
        
        NSTimeInterval lowerBound = PBMTimeInterval.CLOSE_DELAY_MIN;
        NSTimeInterval upperBound = MIN(videoDuration, PBMTimeInterval.CLOSE_DELAY_MAX);
        NSTimeInterval ret = [PBMFunctions clamp:pubCloseDelay lowerBound:lowerBound upperBound:upperBound];
        
        return ret;
    }
}

- (NSNumber *)calculateRewardTime {
    if (!self.creativeModel.adConfiguration.isRewarded) {
        return @-1;
    }
    
    NSString * ortbPlaybackevent = self.rewardedConfig.videoPlaybackevent;
    NSNumber * ortbVideoTime = self.rewardedConfig.videoTime;
    
    // If both complition criteria are missing (playbackevent and time) - use default configuration
    if (!ortbPlaybackevent && !ortbVideoTime) {
        ortbPlaybackevent = self.rewardedConfig.defaultVideoPlaybackEvent;
    }
    
    CGFloat videoDuration = [self.creativeModel.displayDurationInSeconds doubleValue];
    
    // If completion criteria is playback event
    if (ortbPlaybackevent) {
        PBMTrackingEvent event = [PBMTrackingEventDescription getEventWith:ortbPlaybackevent];
        
        switch(event) {
            case PBMTrackingEventStart:
                return @0;
            case PBMTrackingEventFirstQuartile:
                return @(0.25 * videoDuration);
            case PBMTrackingEventMidpoint:
                return @(0.5 * videoDuration);
            case PBMTrackingEventThirdQuartile:
                return @(0.75 * videoDuration);
            case PBMTrackingEventComplete:
                return @(videoDuration);
            default:
                return @(videoDuration);
        }
    }
    
    // If completion criteria is time and if 0 <= completion.video.time <= videoDuration
    if (ortbVideoTime && [ortbVideoTime doubleValue] >= 0 && [ortbVideoTime doubleValue] <= videoDuration) {
        double rewardTime = [ortbVideoTime doubleValue];
        return [NSNumber numberWithDouble:rewardTime];
    }
    
    // Return video duration by default
    return @(videoDuration);
}

- (NSNumber *)calculatePostRewardTimeWith:(NSNumber *)calculatedRewardTime {
    NSNumber * checkedRewardTime = (!calculatedRewardTime || [calculatedRewardTime doubleValue] < 0.0)
    ? @0.0 : calculatedRewardTime;
    
    NSNumber * ortbPostrewardedTime = self.rewardedConfig.postRewardTime;
    NSNumber * checkedPostrewardedTime = (!ortbPostrewardedTime || [ortbPostrewardedTime doubleValue] < 0.0)
    ? @0.0 : ortbPostrewardedTime;
    
    NSNumber * postRewardTime = [NSNumber numberWithDouble:
                                 [checkedRewardTime doubleValue] + [checkedPostrewardedTime doubleValue]];
    
    return postRewardTime;
}

@end
