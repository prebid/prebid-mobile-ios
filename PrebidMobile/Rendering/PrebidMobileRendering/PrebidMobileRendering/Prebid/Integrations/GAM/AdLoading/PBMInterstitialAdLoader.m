//
//  PBMInterstitialAdLoader.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMInterstitialAdLoader.h"

#import "PBMAdLoaderFlowDelegate.h"
#import "PBMInterstitialEventHandler.h"
#import "PBMInterstitialControllerLoadingDelegate.h"
#import "PBMRewardedEventHandler.h"

#import "PBMMacros.h"

#import "PBMPlayable.h"
#import "PBMAdViewManagerDelegate.h"
#import "PBMConstants.h"
#import "PBMDataAssetType.h"
#import "PBMJsonCodable.h"

#import "PBMNativeEventType.h"
#import "PBMNativeEventTrackingMethod.h"

#import "PBMNativeContextType.h"
#import "PBMNativeContextSubtype.h"
#import "PBMNativePlacementType.h"
#import "PBMBaseAdUnit.h"
#import "PBMBidRequesterFactoryBlock.h"
#import "PBMWinNotifierBlock.h"

#import "PBMImageAssetType.h"
#import "PBMNativeAdElementType.h"

#import "PBMBaseInterstitialAdUnit.h"
#import "PBMAdFormat.h"

#import "PBMAdLoadFlowControllerDelegate.h"
#import "PBMBannerAdLoaderDelegate.h"
#import "PBMBannerEventInteractionDelegate.h"
#import "PBMAdPosition.h"
#import "PBMVideoPlacementType.h"
#import "PBMDisplayViewInteractionDelegate.h"

#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

@interface PBMInterstitialAdLoader () <PBMInterstitialControllerLoadingDelegate>
@property (nonatomic, weak, nullable, readonly) id<PBMInterstitialAdLoaderDelegate> delegate;
@end



@implementation PBMInterstitialAdLoader

@synthesize flowDelegate = _flowDelegate;

// MARK: - Lifecycle

- (instancetype)initWithDelegate:(id<PBMInterstitialAdLoaderDelegate>)delegate {
    if (!(self = [super init])) {
        return nil;
    }
    _delegate = delegate;
    return self;
}

// MARK: - PBMAdLoaderProtocol

- (id<PBMPrimaryAdRequesterProtocol>)primaryAdRequester {
    return self.delegate.eventHandler;
}

- (void)createPrebidAdWithBid:(PBMBid *)bid
                 adUnitConfig:(PBMAdUnitConfig *)adUnitConfig
                adObjectSaver:(void (^)(id))adObjectSaver
            loadMethodInvoker:(void (^)(dispatch_block_t))loadMethodInvoker
{
    InterstitialController * const controller = [[InterstitialController alloc] initWithBid:bid
                                                                                  adConfiguration:adUnitConfig];
    adObjectSaver(controller);
    @weakify(self);
    loadMethodInvoker(^{
        @strongify(self);
        controller.loadingDelegate = self;
        [self.delegate interstitialAdLoader:self createdInterstitialController:controller];
        [controller loadAd];
    });
}

- (void)reportSuccessWithAdObject:(id)adObject adSize:(nullable NSValue *)adSize {
    if ([adObject isKindOfClass:[InterstitialController class]]) {
        InterstitialController * const controller = (InterstitialController *)adObject;
        [self.delegate interstitialAdLoader:self
                                   loadedAd:^(UIViewController *targetController) {
            [controller show];
        } isReadyBlock:^BOOL{
            return YES;
        }];
        return;
    }
    if ([adObject conformsToProtocol:@protocol(PBMInterstitialEventHandler)]) {
        id<PBMInterstitialEventHandler> const eventHandler = (id<PBMInterstitialEventHandler>)adObject;
        [self.delegate interstitialAdLoader:self
                                   loadedAd:^(UIViewController *targetController) {
            [eventHandler showFromViewController:targetController];
        } isReadyBlock:^BOOL{
            return eventHandler.isReady;
        }];
        return;
    } else if ([adObject conformsToProtocol:@protocol(PBMRewardedEventHandler)]) {
        id<PBMRewardedEventHandler> const eventHandler = (id<PBMRewardedEventHandler>)adObject;
        [self.delegate interstitialAdLoader:self
                                   loadedAd:^(UIViewController *targetController) {
            [eventHandler showFromViewController:targetController];
        } isReadyBlock:^BOOL{
            return eventHandler.isReady;
        }];
        return;
    }
    [self.delegate interstitialAdLoader:self
                               loadedAd:^(UIViewController *targetController) { } // nop
                           isReadyBlock:^BOOL{ return NO;
        
    }];
}

// MARK: - PBMInterstitialControllerLoadingDelegate

- (void)interstitialControllerDidLoadAd:(InterstitialController *)interstitialController {
    [self.flowDelegate adLoaderLoadedPrebidAd:self];
}

- (void)interstitialController:(InterstitialController *)interstitialController didFailWithError:(NSError *)error {
    [self.flowDelegate adLoader:self failedWithPrebidError:error];
}

// MARK: - PBMInterstitialEventLoadingDelegate

- (void)prebidDidWin {
    [self.flowDelegate adLoaderDidWinPrebid:self];
}

- (void)adServerDidWin {
    [self.flowDelegate adLoader:self loadedPrimaryAd:self.delegate.eventHandler adSize:nil];
}

- (void)failedWithError:(nullable NSError *)error {
    [self.flowDelegate adLoader:self failedWithPrimarySDKError:error];
}

// MARK: - PBMRewardedEventLoadingDelegate

- (NSObject *)reward {
    id<PBMInterstitialAdLoaderDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(reward)]) {
        return [delegate reward];
    }
    return nil;
}

- (void)setReward:(NSObject *)reward {
    id<PBMInterstitialAdLoaderDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(setReward:)]) {
        return [delegate setReward:reward];
    }
}

@end
