//
//  MPInlineAdAdapter+MPAdAdapter.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPInlineAdAdapter+MPAdAdapter.h"
#import "MPInlineAdAdapter+Private.h"

@implementation MPInlineAdAdapter (MPAdAdapter)

@dynamic adUnitId;
@dynamic adapterDelegate;
@dynamic analyticsTracker;

- (id<MPAdAdapterInlineEventDelegate> _Nullable)inlineAdAdapterDelegate {
    if ([self.adapterDelegate conformsToProtocol:@protocol(MPAdAdapterInlineEventDelegate)]) {
        return (id<MPAdAdapterInlineEventDelegate>)self.adapterDelegate;
    }
    else {
        return nil;
    }
}

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration targeting:(MPAdTargeting *)targeting {
    self.configuration = configuration;

    [self startTimeoutTimer];

    self.localExtras = targeting.localExtras;

    [self requestAdWithSize:targeting.creativeSafeSize adapterInfo:configuration.adapterClassData adMarkup:configuration.advancedBidPayload];
}

- (void)didPresentInlineAd {
    if ([self enableAutomaticImpressionAndClickTracking]) {
        [self startViewableTrackingTimer];
    }

    [self didDisplayAd];
}

@end
