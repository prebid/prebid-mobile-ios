//
//  MPMoPubFullscreenAdAdapter.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMoPubFullscreenAdAdapter.h"

#import "MPFullscreenAdAdapter+Private.h"
#import "MPRealTimeTimer.h"

@interface MPMoPubFullscreenAdAdapter ()

@property (nonatomic, strong) MPRealTimeTimer * expirationTimer;

@end

@implementation MPMoPubFullscreenAdAdapter

- (void)didLoadAd {
    [super didLoadAd];

    // Set up timer for expiration for MoPub-specific ads
    __weak __typeof__(self) weakSelf = self;
    self.expirationTimer = [[MPRealTimeTimer alloc] initWithInterval:[MPConstants adsExpirationInterval] block:^(MPRealTimeTimer *timer) {
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        if (strongSelf && !strongSelf.hasTrackedImpression) {
            [strongSelf.delegate fullscreenAdAdapterDidExpire:strongSelf];
        }
        [strongSelf.expirationTimer invalidate];
    }];
    [self.expirationTimer scheduleNow];
}

- (void)trackImpression {
    [super trackImpression];

    // Invalidate the expiration timer because an ad can't expire after its impression is tracked
    [self.expirationTimer invalidate];
}

@end
