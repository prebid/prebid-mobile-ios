//
//  MPFullscreenAdAdapter+MPFullscreenAdViewControllerDelegate.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdContainerView.h"
#import "MPError.h"
#import "MPFullscreenAdAdapter+MPFullscreenAdViewControllerDelegate.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPFullscreenAdViewController+Private.h"
#import "MPLogging.h"
#import "MPViewabilityManager.h"
#import "NSObject+MPAdditions.h"

@implementation MPFullscreenAdAdapter (AppearanceDelegate)

- (void)fullscreenAdWillAppear:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
}

- (void)fullscreenAdDidAppear:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
}

- (void)fullscreenAdWillDisappear:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

- (void)fullscreenAdDidDisappear:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
}

- (void)fullscreenAdWillDismiss:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // Stop the Viewability tracker here. `fullscreenAdWillDismiss:` is invoked before
    // `fullscreenAdWillDisappear:` so this is the earliest termination spot.
    [self stopViewabilitySession];

    [self.delegate fullscreenAdAdapterAdWillDismiss:self];
}

- (void)fullscreenAdDidDismiss:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // Deallocate the `viewController` as we don't need it anymore. If we don't deallocate the
    // `viewController` after dismissal, then the ad content might continue to run, which could lead
    // to bugs such as continuing to play the sound of a video since the app may hold onto the
    // ad controller. Moreover, we keep an array of controllers around as well.
    self.viewController = nil;
    self.hasAdAvailable = NO;

    [self.delegate fullscreenAdAdapterAdDidDismiss:self];
}

@end

#pragma mark -

@implementation MPFullscreenAdAdapter (WebAdDelegate)

- (void)fullscreenAdViewController:(id<MPFullscreenAdViewController>)fullscreenAdViewController webSessionWillStartInView:(MPAdContainerView *)containerView {
    // The following logic only applies to web-based creatives.
    if (self.adContentType != MPAdContentTypeWebNoMRAID && self.adContentType != MPAdContentTypeWebWithMRAID) {
        return;
    }

    // By this time, the webview for the `FullscreenAdViewController` should be created and
    // initialized. Create the Viewability tracker now.
    self.viewabilityTracker = [self viewabilityTrackerForWebContentInView:containerView];
}

- (NSString *)fullscreenAdViewController:(id<MPFullscreenAdViewController>)fullscreenAdViewController willLoadHTML:(NSString *)html inWebView:(MPWebView *)webView {
    return [MPViewabilityManager.sharedManager injectViewabilityIntoAdMarkup:html];
}

- (void)fullscreenWebAdSessionReady:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    // The following logic only applies to web-based creatives.
    if (self.adContentType != MPAdContentTypeWebNoMRAID && self.adContentType != MPAdContentTypeWebWithMRAID) {
        return;
    }

    // The webview has finished navigating, it is safe to start the tracking session.
    [self.viewabilityTracker startTracking];
}

- (void)fullscreenWebAdDidLoad:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:self.className], self.adUnitId);
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)fullscreenWebAdDidFailToLoad:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    NSString *message = [NSString stringWithFormat:@"Failed to load creative:\n%@", self.configuration.adResponseHTMLString];
    NSError *error = [NSError errorWithCode:MOPUBErrorAdapterFailedToLoadAd localizedDescription:message];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:self.className error:error], self.adUnitId);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)fullscreenWebAdDidReceiveTap:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
}

- (void)fullscreenWebAdWillLeaveApplication:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)fullscreenWebAdDidFulfillRewardRequirement:(id<MPFullscreenAdViewController>)fullscreenAdViewController {
    [self.delegate fullscreenAdAdapter:self willRewardUser:self.configuration.selectedReward];
}

@end
