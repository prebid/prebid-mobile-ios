//
//  MPFullscreenAdAdapter.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdAdapterError.h"
#import "MPAdConfiguration.h"
#import "MPAdContainerView+Private.h"
#import "MPAdServerURLBuilder.h"
#import "MPAdTargeting.h"
#import "MPAnalyticsTracker.h"
#import "MPConstants.h"
#import "MPCoreInstanceProvider.h"
#import "MPError.h"
#import "MPFullscreenAdAdapter+Image.h"
#import "MPFullscreenAdAdapter+MPAdAdapter.h"
#import "MPFullscreenAdAdapter+MPFullscreenAdAdapterDelegate.h"
#import "MPFullscreenAdAdapter+MPFullscreenAdViewControllerDelegate.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPFullscreenAdAdapter+Reward.h"
#import "MPFullscreenAdAdapter+Video.h"
#import "MPFullscreenAdAdapter.h"
#import "MPFullscreenAdAdapterDelegate.h"
#import "MPFullscreenAdViewController+MRAIDWeb.h"
#import "MPFullscreenAdViewController+Video.h"
#import "MPFullscreenAdViewController+Web.h"
#import "MPLogging.h"
#import "MPOpenMeasurementTracker.h"
#import "NSObject+MPAdditions.h"

// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif

static const NSUInteger kExcessiveCustomDataLength = 8196;

#pragma mark -

@implementation MPFullscreenAdAdapter

- (void)dealloc {
    if ([self respondsToSelector:@selector(invalidate)]) {
        // Secret API to allow us to detach the adapter from (shared instance) routers synchronously
        [self performSelector:@selector(invalidate)];
    }
    self.delegate = nil;

    [self.adDestinationDisplayAgent cancel];
    [self.timeoutTimer invalidate];

    // The rewarded ad system now no longer holds references to the adapter. The adapter
    // may have a system that holds extra references to the adapter. Let's tell the adapter
    // that we no longer need it.
    [self handleDidInvalidateAd];
}

- (instancetype)init {
    if (self = [super init]) {
        /**
        @c MPFullscreenAdAdapter is playing two historic roles now: both "ad adapter" and an "adapter".
        The "ad adapter" was the upstream object, as well as the delegate of the downstream "adapter"
        object. As two roles consolidated as one now, the "ad adapter" part of @c MPFullscreenAdAdapter is
        the delegate of the "adapter" part of @c MPFullscreenAdAdapter, thus becomes a self delegate.
        */
        _delegate = self; // self delegate by default
        _analyticsTracker = [MPAnalyticsTracker sharedTracker];

        // Viewability tracker creation deferred until load time when
        // more information about the creative is available.
        // For webview creatives, this will be in `fullscreenAdViewController: webSessionWillStartInView:`.
        // For VAST video creatives, this will be in `fetchAndLoadVideoAd`.
        _viewabilityTracker = nil;
    }
    return self;
}

- (void)setUpWithAdConfiguration:(MPAdConfiguration *)adConfiguration localExtras:(NSDictionary *)localExtras {
    self.adContentType = adConfiguration.adContentType;
    self.configuration = adConfiguration;
    self.localExtras = localExtras;

    switch (self.adContentType) {
        case MPAdContentTypeImage:
            _adDestinationDisplayAgent = [MPAdDestinationDisplayAgent agentWithDelegate:self];
            break;
        case MPAdContentTypeVideo:
            _adDestinationDisplayAgent = [MPAdDestinationDisplayAgent agentWithDelegate:self];
            _mediaFileCache = [MPDiskLRUCache sharedDiskCache];
            break;
        case MPAdContentTypeUndefined:
        case MPAdContentTypeWebNoMRAID:
        case MPAdContentTypeWebWithMRAID:
            // intentional `switch` fallthrough: no op
            break;
    }
}

- (void)setCustomData:(NSString *)customData {
    NSUInteger customDataLength = customData.length;
    // Only persist the custom data field if it's non-empty and there is a server-to-server
    // callback URL. The persisted custom data will be url encoded.
    if (customDataLength > 0 && self.configuration.rewardedVideoCompletionUrls.count > 0) {
        // Warn about excessive custom data length, but allow the custom data to be sent anyway
        if (customDataLength > kExcessiveCustomDataLength) {
            MPLogInfo(@"Custom data length %lu exceeds the receommended maximum length of %lu characters.",
                      (unsigned long)customDataLength, (unsigned long)kExcessiveCustomDataLength);
        }

        _customData = customData;
    }
}

- (void)startTimeoutTimer {
    NSTimeInterval timeInterval = FULLSCREEN_TIMEOUT_INTERVAL;
    if (self.configuration && self.configuration.adTimeoutInterval >= 0) {
        timeInterval = self.configuration.adTimeoutInterval;
    }

    if (timeInterval > 0) {
        __typeof__(self) __weak weakSelf = self;
        self.timeoutTimer = [[MPResumableTimer alloc] initWithInterval:timeInterval repeats:NO runLoopMode:NSDefaultRunLoopMode closure:^(MPResumableTimer *timer) {
            __typeof__(self) strongSelf = weakSelf;
            [strongSelf timeout];
        }];
        [self.timeoutTimer scheduleNow];
    }
}

- (void)timeout {
    NSError *error = [NSError errorWithCode:MOPUBErrorAdRequestTimedOut localizedDescription:@"Rewarded ad request timed out"];
    [self.adapterDelegate adapter:self didFailToLoadAdWithError:error];
    self.adapterDelegate = nil;
}

- (void)didLoadAd {
    // Don't report multiple successful loads. Backing ad networks may replenish their caches
    // triggering multiple successful load callbacks.
    if (self.hasSuccessfullyLoaded) {
        return;
    }

    // Update state
    self.hasSuccessfullyLoaded = YES;
    self.hasAdAvailable = YES;
    [self didStopLoadingAd];

    // Track the ad load event for viewability
    [self.viewabilityTracker trackAdLoaded];

    // Notify listeners of the ad load event
    [self.adapterDelegate adAdapter:self handleFullscreenAdEvent:MPFullscreenAdEventDidLoad];
}

- (void)didStopLoadingAd {
    [self.timeoutTimer invalidate];
}

- (NSArray<NSURL *> * _Nullable)rewardedVideoCompletionUrlsByAppendingClientParams {
    if (self.configuration.rewardedVideoCompletionUrls.count == 0) {
        return nil;
    }

    NSMutableArray<NSURL *> * completionUrls = [NSMutableArray arrayWithCapacity:self.configuration.rewardedVideoCompletionUrls.count];

    for (NSString *sourceCompletionUrl in self.configuration.rewardedVideoCompletionUrls) {
        NSString *adapterClassName = NSStringFromClass(self.configuration.adapterClass);

        NSString *customerId = nil;
        if ([self.adapterDelegate respondsToSelector:@selector(customerId)]) {
            customerId = self.adapterDelegate.customerId;
        }

        MPReward *reward = nil;
        if (self.configuration.selectedReward.isCurrencyTypeSpecified) {
            reward = self.configuration.selectedReward;
        }

        NSURL *completionUrl = [MPAdServerURLBuilder rewardedCompletionUrl:sourceCompletionUrl
                                                            withCustomerId:customerId
                                                                rewardType:reward.currencyType
                                                              rewardAmount:reward.amount
                                                          adapterClassName:adapterClassName
                                                            additionalData:self.customData];
        [completionUrls addObject:completionUrl];
    }

    return completionUrls;
}

- (void)handleAdEvent:(MPFullscreenAdEvent)event {
    switch (event) {
        case MPFullscreenAdEventDidLoad:
            [self didLoadAd];
            break;
        case MPFullscreenAdEventDidAppear:
            if (self.enableAutomaticImpressionAndClickTracking) {
                [self trackImpression];
            }
            [self.adapterDelegate adAdapter:self handleFullscreenAdEvent:event];
            break;
        case MPFullscreenAdEventDidExpire:
            // Only allow one expire per adapter to match up with one successful load callback per adapter.
            if (self.hasExpired) {
                return;
            }
            self.hasExpired = YES;
            [self.adapterDelegate adAdapter:self handleFullscreenAdEvent:event];
            break;
        case MPFullscreenAdEventDidReceiveTap:
            if (self.enableAutomaticImpressionAndClickTracking) {
                [self trackClick];
            }
            [self.adapterDelegate adAdapter:self handleFullscreenAdEvent:event];
            break;
        // intentionally fall through for default delegate callback
        case MPFullscreenAdEventWillAppear:
        case MPFullscreenAdEventWillDisappear:
        case MPFullscreenAdEventDidDisappear:
        case MPFullscreenAdEventWillLeaveApplication:
        case MPFullscreenAdEventWillDismiss:
        case MPFullscreenAdEventDidDismiss:
            [self.adapterDelegate adAdapter:self handleFullscreenAdEvent:event];
            break;
    }
}

- (void)trackClick {
    if (self.hasTrackedClick) {
        return;
    }

    self.hasTrackedClick = YES;
    [self.analyticsTracker trackClickForConfiguration:self.configuration];
}

- (void)trackImpression {
    if (self.hasTrackedImpression) {
        return;
    }

    // Update state
    self.hasTrackedImpression = YES;

    // Fire trackers
    [self.analyticsTracker trackImpressionForConfiguration:self.configuration];
    [self.viewabilityTracker trackImpression];

    // Notify listeners
    [self.adapterDelegate adDidReceiveImpressionEventForAdapter:self];
}

#pragma mark - Viewability

// Viewability tracker creation abstracted out in case it needs to be overridden for testing.
// This interface is defined in `MPFullscreenAdAdapter+Private.h`
- (id<MPViewabilityTracker> _Nullable)viewabilityTrackerForWebContentInView:(MPAdContainerView *)webContainer {
    // No view to track
    if (webContainer == nil) {
        MPLogEvent([MPLogEvent error:[NSError noViewToTrack] message:@"Failed to initialize Viewability tracker"]);
        return nil;
    }

    NSSet<UIView<MPViewabilityObstruction> *> *obstructions = webContainer.friendlyObstructions;
    MPOpenMeasurementTracker *tracker = [[MPOpenMeasurementTracker alloc] initWithWebView:webContainer.webContentView
                                                                          containedInView:webContainer
                                                                     friendlyObstructions:obstructions];
    if (tracker != nil) {
        MPLogEvent([MPLogEvent viewabilityTrackerCreated:tracker]);
    }

    // Update the container with a weak reference to the newly create tracker.
    // This is to allow friendly obstruction updates to the tracker as the
    // container's UI changes.
    webContainer.viewabilityTracker = tracker;

    return tracker;
}

// Viewability tracker creation abstracted out in case it needs to be overridden for testing.
// This interface is defined in `MPFullscreenAdAdapter+Private.h`
- (id<MPViewabilityTracker> _Nullable)viewabilityTrackerForVideoConfig:(MPVideoConfig *)config
                                              containedInContainerView:(MPAdContainerView *)container
                                                       adConfiguration:(MPAdConfiguration *)adConfiguration {
    // No view to track
    if (container == nil) {
        MPLogEvent([MPLogEvent error:[NSError noViewToTrack] message:@"Failed to initialize Viewability tracker"]);
        return nil;
    }

    // Add the contents of the ad configuration context to the video config context to capture
    // any additional viewability trackers that need to be fired in addition to the ones in
    // the VAST XML.
    MPViewabilityContext *additionalContext = adConfiguration.viewabilityContext;
    if (additionalContext != nil) {
        [config.viewabilityContext addObjectsFromContext:additionalContext];
    }

    MPOpenMeasurementTracker *tracker = [[MPOpenMeasurementTracker alloc] initWithVASTPlayerView:container videoConfig:config];
    if (tracker != nil) {
        MPLogEvent([MPLogEvent viewabilityTrackerCreated:tracker]);
    }

    // Update the container with a weak reference to the newly create tracker.
    // This is to allow friendly obstruction updates to the tracker as the
    // container's UI changes.
    container.viewabilityTracker = tracker;

    return tracker;
}

@end

#pragma mark -

@implementation MPFullscreenAdAdapter (MPFullscreenAdAdapter)

@dynamic localExtras;

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

- (BOOL)isRewardExpected {
    return (self.configuration.rewardedDuration > 0);
}

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    MPAdConfiguration *configuration = self.configuration;
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:self.className
                                       dspCreativeId:configuration.dspCreativeId
                                             dspName:nil], self.adUnitId);
    switch (self.adContentType) {
        case MPAdContentTypeUndefined:
            break; // no op
        case MPAdContentTypeVideo:
            [self fetchAndLoadVideoAd];
            break;
        case MPAdContentTypeImage:
            [self loadImageAd];
            break;
        case MPAdContentTypeWebNoMRAID:
            self.viewController = [[MPFullscreenAdViewController alloc] initWithAdContentType:self.adContentType];
            self.viewController.appearanceDelegate = self;
            self.viewController.webAdDelegate = self;
            self.viewController.countdownTimerDelegate = self;
            self.viewController.orientationType = configuration.orientationType; // not a concern for MRAID ads
            [self.viewController loadConfigurationForWebAd:configuration];
            if (self.isRewardExpected) {
                [self.viewController setRewardCountdownDuration:self.rewardCountdownDuration];
            }
            break;
        case MPAdContentTypeWebWithMRAID:
            self.viewController = [[MPFullscreenAdViewController alloc] initWithAdContentType:self.adContentType];
            self.viewController.appearanceDelegate = self;
            self.viewController.webAdDelegate = self;
            self.viewController.countdownTimerDelegate = self;
            [self.viewController loadConfigurationForMRAIDAd:configuration];

            // Determine whether to display the countdown timer. In general, the timer will be displayed
            // if there is a rewarded duration.
            if (self.isRewardExpected) {
                // Render the countdown timer.
                [self.viewController setRewardCountdownDuration:self.rewardCountdownDuration];
            }
            break;
    }
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:self.className], self.adUnitId);
    if (self.viewController.presentingViewController) {
        MPLogInfo(@"View controller has been presented");
        return;
    }
    else if (viewController.presentedViewController) {
        MPLogInfo(@"Root view controller has presented a view controller");
        return;
    }

    __typeof__(self) __weak weakSelf = self;
    void (^handler)(NSError *) = ^(NSError * error) {
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        };

        if (error != nil) {
            MPLogAdEvent([MPLogEvent adShowFailedForAdapter:strongSelf.className error:error], strongSelf.adUnitId);
            [strongSelf.viewController showCloseButton];
            [strongSelf.delegate fullscreenAdAdapter:strongSelf didFailToShowAdWithError:error];
        }
        else {
            MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:strongSelf.className], strongSelf.adUnitId);
            if (self.adContentType == MPAdContentTypeVideo) {
                [strongSelf.viewController playVideo];
            }
        }
    };

    if (self.hasAdAvailable) {
        [self.viewController presentFromViewController:viewController complete:handler];
    }
    else {
        handler([NSError errorWithAdAdapterErrorCode:MPAdAdapterErrorCodeNoAdsAvailable]);
    }
}

- (void)handleDidInvalidateAd {
    // Subclasses may override this method to handle when the adapter is no longer needed.
}

- (void)handleDidPlayAd {
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to handle when another ad unit plays an ad for the same ad network this
    // adapter is representing.
}

- (void)stopViewabilitySession {
    [self.viewabilityTracker stopTracking];
}

@end

#pragma mark -

@implementation MPFullscreenAdAdapter (MPCountdownTimerDelegate)

- (void)countdownTimerDidFinishCountdown:(id)source {
    [self provideRewardToUser:self.configuration.selectedReward
   forRewardCountdownComplete:YES
              forUserInteract:NO];
}

@end
