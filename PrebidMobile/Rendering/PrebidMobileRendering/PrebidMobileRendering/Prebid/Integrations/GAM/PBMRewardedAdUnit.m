//
//  PBMRewardedAdUnit.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMRewardedAdUnit.h"
#import "PBMRewardedAdUnit+Protected.h"

#import "PBMBaseInterstitialAdUnit+Protected.h"
#import "PBMInterstitialController.h"

#import "PBMRewardedEventHandler.h"
#import "PBMRewardedEventHandlerStandalone.h"

#import "PBMMacros.h"



@implementation PBMRewardedAdUnit

// MARK: - Lifecycle

- (instancetype)initWithConfigId:(NSString *)configId
                    eventHandler:(id<PBMRewardedEventHandler>)eventHandler {
    if (!(self = [super initWithConfigId:configId eventHandler:eventHandler])) {
        return nil;
    }
    self.adUnitConfig.isOptIn = YES;
    self.adFormat = PBMAdFormatVideo;
    return self;
}

- (instancetype)initWithConfigId:(NSString *)configId {
    return (self = [self initWithConfigId:configId eventHandler:[[PBMRewardedEventHandlerStandalone alloc] init]]);
}

// MARK: - PBMRewardedEventDelegate

- (void)userDidEarnReward:(nullable NSObject *)reward {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self callDelegate_rewardedAdUserDidEarnReward];
    });
}

// MARK: - PBMInterstitialControllerDelegate protocol

- (void)interstitialControllerDidCloseAd:(PBMInterstitialController *)interstitialController {
    [self callDelegate_rewardedAdUserDidEarnReward];
    [super interstitialControllerDidCloseAd:interstitialController];
}

// MARK: - Private helpers

- (void)callDelegate_rewardedAdUserDidEarnReward {
    id<PBMRewardedAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(rewardedAdUserDidEarnReward:)]) {
        [delegate rewardedAdUserDidEarnReward:self];
    }
}

// MARK: - Protected overrides

- (void)callDelegate_didReceiveAd {
    id<PBMRewardedAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(rewardedAdDidReceiveAd:)]) {
        [delegate rewardedAdDidReceiveAd:self];
    }
}

- (void)callDelegate_didFailToReceiveAdWithError:(NSError *)error {
    id<PBMRewardedAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(rewardedAd:didFailToReceiveAdWithError:)]) {
        [delegate rewardedAd:self didFailToReceiveAdWithError:error];
    }
}

- (void)callDelegate_willPresentAd {
    id<PBMRewardedAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(rewardedAdWillPresentAd:)]) {
        [delegate rewardedAdWillPresentAd:self];
    }
}

- (void)callDelegate_didDismissAd {
    id<PBMRewardedAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(rewardedAdDidDismissAd:)]) {
        [delegate rewardedAdDidDismissAd:self];
    }
}

- (void)callDelegate_willLeaveApplication {
    id<PBMRewardedAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(rewardedAdWillLeaveApplication:)]) {
        [delegate rewardedAdWillLeaveApplication:self];
    }
}

- (void)callDelegate_didClickAd {
    id<PBMRewardedAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(rewardedAdDidClickAd:)]) {
        [delegate rewardedAdDidClickAd:self];
    }
}

- (BOOL)callEventHandler_isReady {
    return self.eventHandler.isReady;
}

- (void)callEventHandler_setLoadingDelegate:(id<PBMRewardedEventLoadingDelegate>)loadingDelegate {
    self.eventHandler.loadingDelegate = loadingDelegate;
}

- (void)callEventHandler_setInteractionDelegate {
    self.eventHandler.interactionDelegate = self;
}

- (void)callEventHandler_requestAdWithBidResponse:(nullable PBMBidResponse *)bidResponse {
    [self.eventHandler requestAdWithBidResponse:bidResponse];
}

- (void)callEventHandler_showFromViewController:(nullable UIViewController *)controller {
    [self.eventHandler showFromViewController:controller];
}

- (void)callEventHandler_trackImpression {
    if ([self.eventHandler respondsToSelector:@selector(trackImpression)]) {
        [self.eventHandler trackImpression];
    }
}

@end
