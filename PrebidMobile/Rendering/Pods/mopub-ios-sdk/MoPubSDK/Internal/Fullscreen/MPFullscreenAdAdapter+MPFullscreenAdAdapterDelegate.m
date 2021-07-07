//
//  MPFullscreenAdAdapter+MPFullscreenAdAdapterDelegate.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdAdapter+MPAdAdapter.h"
#import "MPFullscreenAdAdapter+MPFullscreenAdAdapterDelegate.h"
#import "MPFullscreenAdAdapter+Private.h"
#import "MPFullscreenAdAdapter+Reward.h"

@implementation MPFullscreenAdAdapter (MPFullscreenAdAdapterDelegate)

- (NSString *)customerIdForAdapter:(MPFullscreenAdAdapter *)adapter {
    if ([self.adapterDelegate respondsToSelector:@selector(customerId)]) {
        return [self.adapterDelegate customerId];
    }

    return nil;
}

- (id<MPMediationSettingsProtocol>)fullscreenAdAdapter:(MPFullscreenAdAdapter *)adapter instanceMediationSettingsForClass:(Class)aClass {
    if ([self.adapterDelegate respondsToSelector:@selector(instanceMediationSettingsForClass:)]) {
        return [self.adapterDelegate instanceMediationSettingsForClass:aClass];
    }

    return nil;
}

- (void)fullscreenAdAdapter:(MPFullscreenAdAdapter *)adapter didFailToLoadAdWithError:(NSError *)error {
    // Invalidate the ad adapter. An ad *may* end up, after some time, loading successfully
    // from the underlying network, but we don't want to bubble up the event to the application since we
    // are possibly reporting a timeout here.
    [self handleDidInvalidateAd];

    self.hasAdAvailable = NO;
    [self.viewController showCloseButton];
    [self didStopLoadingAd];
    [self.adapterDelegate adapter:self didFailToLoadAdWithError:error];
}

- (void)fullscreenAdAdapter:(MPFullscreenAdAdapter *)adapter didFailToShowAdWithError:(NSError *)error {
    self.hasAdAvailable = NO;
    [self.adapterDelegate adapter:self didFailToPlayAdWithError:error];
}

- (void)fullscreenAdAdapter:(MPFullscreenAdAdapter *)adapter willRewardUser:(MPReward *)reward {
    [self provideRewardToUser:reward forRewardCountdownComplete:YES forUserInteract:NO];
}

- (void)fullscreenAdAdapterDidTrackClick:(MPFullscreenAdAdapter *)adapter {
    [self trackClick];
}

- (void)fullscreenAdAdapterDidTrackImpression:(MPFullscreenAdAdapter *)adapter {
    [self trackImpression];
}

- (void)fullscreenAdAdapterAdDidAppear:(MPFullscreenAdAdapter *)adapter {
    [self handleAdEvent:MPFullscreenAdEventDidAppear];
}


- (void)fullscreenAdAdapterAdDidDisappear:(MPFullscreenAdAdapter *)adapter {
    [self handleAdEvent:MPFullscreenAdEventDidDisappear];
}


- (void)fullscreenAdAdapterAdWillAppear:(MPFullscreenAdAdapter *)adapter {
    [self handleAdEvent:MPFullscreenAdEventWillAppear];
}


- (void)fullscreenAdAdapterAdWillDisappear:(MPFullscreenAdAdapter *)adapter {
    [self handleAdEvent:MPFullscreenAdEventWillDisappear];
}


- (void)fullscreenAdAdapterDidExpire:(MPFullscreenAdAdapter *)adapter {
    [self handleAdEvent:MPFullscreenAdEventDidExpire];
}


- (void)fullscreenAdAdapterDidLoadAd:(MPFullscreenAdAdapter *)adapter {
    [self handleAdEvent:MPFullscreenAdEventDidLoad];
}


- (void)fullscreenAdAdapterDidReceiveTap:(MPFullscreenAdAdapter *)adapter {
    [self handleAdEvent:MPFullscreenAdEventDidReceiveTap];
}


- (void)fullscreenAdAdapterWillLeaveApplication:(MPFullscreenAdAdapter *)adapter {
    [self handleAdEvent:MPFullscreenAdEventWillLeaveApplication];
}

- (void)fullscreenAdAdapterAdWillDismiss:(MPFullscreenAdAdapter *)adapter {
    [self handleAdEvent:MPFullscreenAdEventWillDismiss];
}

- (void)fullscreenAdAdapterAdDidDismiss:(MPFullscreenAdAdapter *)adapter {
    [self handleAdEvent: MPFullscreenAdEventDidDismiss];
}

@end
