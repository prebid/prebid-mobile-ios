//
//  PBMInterstitialAdUnit.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMInterstitialAdUnit.h"

#import "PBMBaseInterstitialAdUnit+Protected.h"

#import "PBMInterstitialEventHandler.h"
#import "PBMInterstitialEventHandlerStandalone.h"

@implementation PBMInterstitialAdUnit

@dynamic adFormat;

// MARK: - Lifecycle

- (instancetype)initWithConfigId:(NSString *)configId {
    return (self = [super initWithConfigId:configId
                              eventHandler:[[PBMInterstitialEventHandlerStandalone alloc] init]]);
}

- (instancetype)initWithConfigId:(NSString *)configId minSizePercentage:(CGSize)minSizePercentage {
    return (self = [super initWithConfigId:configId
                         minSizePercentage:minSizePercentage
                              eventHandler:[[PBMInterstitialEventHandlerStandalone alloc] init]]);
}

- (instancetype)initWithConfigId:(NSString *)configId
               minSizePercentage:(CGSize)minSizePercentage
                    eventHandler:(id<PBMInterstitialEventHandler>)eventHandler {
    return (self = [super initWithConfigId:configId minSizePercentage:minSizePercentage eventHandler:eventHandler]);
}


// MARK: - Protected overrides

- (void)callDelegate_didReceiveAd {
    id<PBMInterstitialAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(interstitialDidReceiveAd:)]) {
        [delegate interstitialDidReceiveAd:self];
    }
}

- (void)callDelegate_didFailToReceiveAdWithError:(NSError *)error {
    id<PBMInterstitialAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(interstitial:didFailToReceiveAdWithError:)]) {
        [delegate interstitial:self didFailToReceiveAdWithError:error];
    }
}

- (void)callDelegate_willPresentAd {
    id<PBMInterstitialAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(interstitialWillPresentAd:)]) {
        [delegate interstitialWillPresentAd:self];
    }
}

- (void)callDelegate_didDismissAd {
    id<PBMInterstitialAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(interstitialDidDismissAd:)]) {
        [delegate interstitialDidDismissAd:self];
    }
}

- (void)callDelegate_willLeaveApplication {
    id<PBMInterstitialAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(interstitialWillLeaveApplication:)]) {
        [delegate interstitialWillLeaveApplication:self];
    }
}

- (void)callDelegate_didClickAd {
    id<PBMInterstitialAdUnitDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(interstitialDidClickAd:)]) {
        [delegate interstitialDidClickAd:self];
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
