//
//  MPInlineAdAdapter+MPInlineAdAdapterDelegate.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInlineAdAdapter+MPInlineAdAdapterDelegate.h"
#import "MPInlineAdAdapter+MPAdAdapter.h"
#import "MPInlineAdAdapter+Private.h"

#import "MPAdAdapter.h"
#import "MPAdEvent.h"
#import "MPError.h"

@implementation MPInlineAdAdapter (MPInlineAdAdapterDelegate)

#pragma mark - MPInlineAdAdapterDelegate

- (UIViewController *)inlineAdAdapterViewControllerForPresentingModalView:(MPInlineAdAdapter *)adapter
{
    return [self.inlineAdAdapterDelegate viewControllerForPresentingModalView];
}

- (void)inlineAdAdapter:(MPInlineAdAdapter *)adapter didLoadAdWithAdView:(UIView *)adView {
    [self didStopLoading];
    if (adView) {
        // Update internally tracked ad view
        self.adView = adView;

        // Track the ad load event for viewability
        [self.viewabilityTracker trackAdLoaded];

        // Notify listeners of the ad load event
        [self.inlineAdAdapterDelegate inlineAdAdapter:self didLoadAdWithAdView:adView];
    } else {
        NSError * noViewError = [NSError errorWithCode:MOPUBErrorInlineNoViewGivenWhenAdLoaded];
        [self.adapterDelegate adapter:self didFailToLoadAdWithError:noViewError];
    }
}

- (void)inlineAdAdapter:(MPInlineAdAdapter *)adapter didFailToLoadAdWithError:(NSError *)error {
    [self didStopLoading];
    [self.adapterDelegate adapter:self didFailToLoadAdWithError:error];
}

- (void)inlineAdAdapterDidTrackClick:(MPInlineAdAdapter *)adapter {
    [self trackClick];
}

- (void)inlineAdAdapterDidTrackImpression:(MPInlineAdAdapter *)adapter {
    [self trackImpression];
}

- (void)inlineAdAdapterWillBeginUserAction:(MPInlineAdAdapter *)adapter {
    [self handleAdEvent:MPInlineAdEventUserActionWillBegin];
}

- (void)inlineAdAdapterDidEndUserAction:(MPInlineAdAdapter *)adapter {
    [self handleAdEvent:MPInlineAdEventUserActionDidEnd];
}

- (void)inlineAdAdapterWillLeaveApplication:(MPInlineAdAdapter *)adapter {
    [self handleAdEvent:MPInlineAdEventWillLeaveApplication];
}

- (void)inlineAdAdapterWillExpand:(MPInlineAdAdapter *)adapter {
    [self handleAdEvent:MPInlineAdEventWillExpand];
}

- (void)inlineAdAdapterDidCollapse:(MPInlineAdAdapter *)adapter {
    [self handleAdEvent:MPInlineAdEventDidCollapse];
}

#pragma mark - Helper

- (void)handleAdEvent:(MPInlineAdEvent)event {
    // Track clicks for UserActionWillBegin and WillLeaveApplication
    // only if enableAutomaticImpressionAndClickTracking is enabled
    if (event == MPInlineAdEventUserActionWillBegin ||
        event == MPInlineAdEventWillLeaveApplication) {
        if (self.enableAutomaticImpressionAndClickTracking) {
            [self trackClick];
        }
    }

    // Send event to delegate
    [self.inlineAdAdapterDelegate adAdapter:self handleInlineAdEvent:event];
}

@end
