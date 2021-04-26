//
//  PBMGAMRewardedEventHandler.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMGAMRewardedEventHandler.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#import <PrebidMobileRendering/PBMBid.h>
#import "PBMGADRewardedAd.h"
#import "PBMGAMError.h"
#import "PBMDFPRequest.h"


static NSString * const appEvent = @"PrebidAppEvent";
static float const appEventTimeout = 0.6f;


@interface PBMGAMRewardedEventHandler () <GADRewardedAdDelegate, GADRewardedAdMetadataDelegate>

@property (nonatomic, strong, nullable) PBMGADRewardedAd *requestRewarded;
@property (nonatomic, strong, nullable) PBMGADRewardedAd *oxbProxyRewarded;
@property (nonatomic, strong, nullable) PBMGADRewardedAd *embeddedRewarded;
@property (nonatomic, strong, readonly, nonnull) NSArray<NSValue *> *adSizes;
@property (nonatomic, assign) BOOL isExpectingAppEvent;

// invalidate <- [self appEventDetected]
// on timeout -> [self appEventTimedOut]
@property (nonatomic, strong, nullable) NSTimer *appEventTimer;

@end



@implementation PBMGAMRewardedEventHandler

@synthesize loadingDelegate = _loadingDelegate;
@synthesize interactionDelegate = _interactionDelegate;

// MARK: - Public API

- (instancetype)initWithAdUnitID:(NSString *)adUnitID {
    if (!(self = [super init])) {
        return nil;
    }
    _adUnitID = [adUnitID copy];
    return self;
}

- (BOOL)isReady {
    if (self.requestRewarded) {
        return NO;
    }
    PBMGADRewardedAd * const loadedRewarded = self.embeddedRewarded ?: self.oxbProxyRewarded;
    return loadedRewarded.isReady;
}

// MARK: - PBMRewardedEventHandler protocol

- (void)requestAdWithBidResponse:(nullable PBMBidResponse *)bidResponse {
    if (!([PBMGADRewardedAd classesFound] && [PBMDFPRequest classesFound])) {
        NSError * const error = [PBMGAMError gamClassesNotFound];
        [PBMGAMError logError:error];
        [self.loadingDelegate failedWithError:error];
        return;
    }
    if (self.requestRewarded) {
        // request to primaryAdServer in progress
        return;
    }
    if (self.oxbProxyRewarded || self.embeddedRewarded) {
        // rewarded already loaded
        return;
    }
    PBMGADRewardedAd * const currentRequestRearded = [[PBMGADRewardedAd alloc] initWithAdUnitID:self.adUnitID];
    self.requestRewarded = currentRequestRearded;
    PBMDFPRequest * const dfpRequest = [[PBMDFPRequest alloc] init];
    if (bidResponse) {
        self.isExpectingAppEvent = bidResponse.winningBid;
        NSMutableDictionary * const targeting = [[NSMutableDictionary alloc] init];
        if (dfpRequest.customTargeting) {
            [targeting addEntriesFromDictionary:dfpRequest.customTargeting];
        }
        if (bidResponse.targetingInfo) {
            [targeting addEntriesFromDictionary:bidResponse.targetingInfo];
        }
        if (targeting.count) {
            dfpRequest.customTargeting = targeting;
        }
    }
    self.requestRewarded.adMetadataDelegate = self;
    // self.requestRewarded.enableManualImpressions = YES; // FIXME: (PB-X) Implement impressions
    
    __weak PBMGAMRewardedEventHandler * const weakSelf = self;
    [currentRequestRearded loadRequest:dfpRequest completionHandler:^(GADRequestError * _Nullable error) {
        PBMGAMRewardedEventHandler * const strongSelf = weakSelf;
        if (error != nil) {
            [strongSelf rewardedAd:currentRequestRearded didFailToReceiveAdWithError:error];
        } else {
            [strongSelf rewardedAdDidReceiveAd:currentRequestRearded];
        }
    }];
}

- (void)showFromViewController:(UIViewController *)controller {
    if (self.embeddedRewarded.isReady) {
        [self.embeddedRewarded presentFromRootViewController:controller delegate:self];
    }
}

- (void)trackImpression {
    // FIXME: (PB-X) Implement impressions
}

// MARK: - PBMGADRewardedAd loading callbacks

- (void)rewardedAdDidReceiveAd:(nonnull PBMGADRewardedAd *)ad {
    if (self.requestRewarded == ad) {
        [self primaryAdReceived];
    }
}

- (void)rewardedAd:(nonnull PBMGADRewardedAd *)ad
    didFailToReceiveAdWithError:(nonnull GADRequestError *)error
{
    if (self.requestRewarded == ad) {
        self.requestRewarded = nil;
        [self forgetCurrentRewarded];
        [self.loadingDelegate failedWithError:error];
    }
}

// MARK: - GADRewardedAdDelegate protocol

/// Tells the delegate that the user earned a reward.
- (void)rewardedAd:(nonnull PBMGADRewardedAd *)rewardedAd
    userDidEarnReward:(nonnull GADAdReward *)reward
{
    [self.interactionDelegate userDidEarnReward:reward];
}

- (void)rewardedAd:(nonnull PBMGADRewardedAd *)rewardedAd
    didFailToPresentWithError:(nonnull NSError *)error
{
    // nop?
}

- (void)rewardedAdDidPresent:(nonnull PBMGADRewardedAd *)rewardedAd {
    [self.interactionDelegate willPresentAd]; // FIXME: (PB-X) Align [will/did present] callbacks
}

- (void)rewardedAdDidDismiss:(nonnull PBMGADRewardedAd *)rewardedAd {
    [self.interactionDelegate didDismissAd];
}

// MARK: - PBMGADRewardedAdMetadataDelegate protocol

- (void)rewardedAdMetadataDidChange:(nonnull PBMGADRewardedAd *)rewardedAd {
    if (self.requestRewarded.boxedRewardedAd == rewardedAd && [rewardedAd.adMetadata[@"AdTitle"] isEqual:appEvent]) {
        [self appEventDetected];
    }
}

// MARK: - Private Helpers

- (void)primaryAdReceived {
    if (self.isExpectingAppEvent) {
        if (self.appEventTimer) {
            return;
        }
        self.appEventTimer = [NSTimer scheduledTimerWithTimeInterval:appEventTimeout
                                                              target:self
                                                            selector:@selector(appEventTimedOut)
                                                            userInfo:nil
                                                             repeats:NO];
    } else {
        // no bids were present in prebid response -- no need to wait for app event
        PBMGADRewardedAd * const dfpRewarded = self.requestRewarded;
        self.requestRewarded = nil;
        [self forgetCurrentRewarded];
        self.embeddedRewarded = dfpRewarded;
        id<PBMRewardedEventLoadingDelegate> const delegate = self.loadingDelegate;
        delegate.reward = dfpRewarded.reward;
        [delegate adServerDidWin];
    }
}

- (void)appEventDetected {
    PBMGADRewardedAd * const dfpRewarded = self.requestRewarded;
    self.requestRewarded = nil;
    if (self.isExpectingAppEvent) {
        if (self.appEventTimer) {
            [self.appEventTimer invalidate];
            self.appEventTimer = nil;
        }
        self.isExpectingAppEvent = NO;
        [self forgetCurrentRewarded];
        self.oxbProxyRewarded = dfpRewarded;
        id<PBMRewardedEventLoadingDelegate> const delegate = self.loadingDelegate;
        delegate.reward = dfpRewarded.reward;
        [delegate prebidDidWin];
    }
}

- (void)appEventTimedOut {
    PBMGADRewardedAd * const dfpRewarded = self.requestRewarded;
    self.requestRewarded = nil;
    [self forgetCurrentRewarded];
    self.embeddedRewarded = dfpRewarded;
    self.isExpectingAppEvent = NO;
    self.appEventTimer = nil;
    id<PBMRewardedEventLoadingDelegate> const delegate = self.loadingDelegate;
    delegate.reward = dfpRewarded.reward;
    [delegate adServerDidWin];
}

- (void)forgetCurrentRewarded {
    if (self.embeddedRewarded) {
        self.embeddedRewarded = nil;
    } else if (self.oxbProxyRewarded) {
        self.oxbProxyRewarded = nil;
        // self.recycledRewarded.enableManualImpressions = NO;  // FIXME: (PB-X) Implement impressions
    }
}

@end
