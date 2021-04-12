//
//  OXAGAMRewardedEventHandler.m
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAGAMRewardedEventHandler.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#import <OpenXApolloSDK/OXABid.h>
#import "OXAGADRewardedAd.h"
#import "OXAGAMError.h"
#import "OXADFPRequest.h"


static NSString * const appEvent = @"OpenXApolloAppEvent";
static float const appEventTimeout = 0.6f;


@interface OXAGAMRewardedEventHandler () <GADRewardedAdDelegate, GADRewardedAdMetadataDelegate>

@property (nonatomic, strong, nullable) OXAGADRewardedAd *requestRewarded;
@property (nonatomic, strong, nullable) OXAGADRewardedAd *oxbProxyRewarded;
@property (nonatomic, strong, nullable) OXAGADRewardedAd *embeddedRewarded;
@property (nonatomic, strong, readonly, nonnull) NSArray<NSValue *> *adSizes;
@property (nonatomic, assign) BOOL isExpectingAppEvent;

// invalidate <- [self appEventDetected]
// on timeout -> [self appEventTimedOut]
@property (nonatomic, strong, nullable) NSTimer *appEventTimer;

@end



@implementation OXAGAMRewardedEventHandler

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
    OXAGADRewardedAd * const loadedRewarded = self.embeddedRewarded ?: self.oxbProxyRewarded;
    return loadedRewarded.isReady;
}

// MARK: - OXARewardedEventHandler protocol

- (void)requestAdWithBidResponse:(nullable OXABidResponse *)bidResponse {
    if (!([OXAGADRewardedAd classesFound] && [OXADFPRequest classesFound])) {
        NSError * const error = [OXAGAMError gamClassesNotFound];
        [OXAGAMError logError:error];
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
    OXAGADRewardedAd * const currentRequestRearded = [[OXAGADRewardedAd alloc] initWithAdUnitID:self.adUnitID];
    self.requestRewarded = currentRequestRearded;
    OXADFPRequest * const dfpRequest = [[OXADFPRequest alloc] init];
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
    
    __weak OXAGAMRewardedEventHandler * const weakSelf = self;
    [currentRequestRearded loadRequest:dfpRequest completionHandler:^(GADRequestError * _Nullable error) {
        OXAGAMRewardedEventHandler * const strongSelf = weakSelf;
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

// MARK: - OXAGADRewardedAd loading callbacks

- (void)rewardedAdDidReceiveAd:(nonnull OXAGADRewardedAd *)ad {
    if (self.requestRewarded == ad) {
        [self primaryAdReceived];
    }
}

- (void)rewardedAd:(nonnull OXAGADRewardedAd *)ad
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
- (void)rewardedAd:(nonnull OXAGADRewardedAd *)rewardedAd
    userDidEarnReward:(nonnull GADAdReward *)reward
{
    [self.interactionDelegate userDidEarnReward:reward];
}

- (void)rewardedAd:(nonnull OXAGADRewardedAd *)rewardedAd
    didFailToPresentWithError:(nonnull NSError *)error
{
    // nop?
}

- (void)rewardedAdDidPresent:(nonnull OXAGADRewardedAd *)rewardedAd {
    [self.interactionDelegate willPresentAd]; // FIXME: (PB-X) Align [will/did present] callbacks
}

- (void)rewardedAdDidDismiss:(nonnull OXAGADRewardedAd *)rewardedAd {
    [self.interactionDelegate didDismissAd];
}

// MARK: - OXAGADRewardedAdMetadataDelegate protocol

- (void)rewardedAdMetadataDidChange:(nonnull OXAGADRewardedAd *)rewardedAd {
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
        OXAGADRewardedAd * const dfpRewarded = self.requestRewarded;
        self.requestRewarded = nil;
        [self forgetCurrentRewarded];
        self.embeddedRewarded = dfpRewarded;
        id<OXARewardedEventLoadingDelegate> const delegate = self.loadingDelegate;
        delegate.reward = dfpRewarded.reward;
        [delegate adServerDidWin];
    }
}

- (void)appEventDetected {
    OXAGADRewardedAd * const dfpRewarded = self.requestRewarded;
    self.requestRewarded = nil;
    if (self.isExpectingAppEvent) {
        if (self.appEventTimer) {
            [self.appEventTimer invalidate];
            self.appEventTimer = nil;
        }
        self.isExpectingAppEvent = NO;
        [self forgetCurrentRewarded];
        self.oxbProxyRewarded = dfpRewarded;
        id<OXARewardedEventLoadingDelegate> const delegate = self.loadingDelegate;
        delegate.reward = dfpRewarded.reward;
        [delegate apolloDidWin];
    }
}

- (void)appEventTimedOut {
    OXAGADRewardedAd * const dfpRewarded = self.requestRewarded;
    self.requestRewarded = nil;
    [self forgetCurrentRewarded];
    self.embeddedRewarded = dfpRewarded;
    self.isExpectingAppEvent = NO;
    self.appEventTimer = nil;
    id<OXARewardedEventLoadingDelegate> const delegate = self.loadingDelegate;
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
