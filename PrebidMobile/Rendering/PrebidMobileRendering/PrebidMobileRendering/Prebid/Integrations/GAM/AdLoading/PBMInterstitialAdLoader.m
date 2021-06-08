//
//  PBMInterstitialAdLoader.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMInterstitialAdLoader.h"

#import "PBMAdLoaderFlowDelegate.h"
#import "PBMInterstitialEventHandler.h"
#import "PBMInterstitialAdLoaderDelegate.h"

#import "PBMMacros.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

@interface PBMInterstitialAdLoader () <InterstitialControllerLoadingDelegate, RewardedEventLoadingDelegate>
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

- (void)createPrebidAdWithBid:(Bid *)bid
                 adUnitConfig:(AdUnitConfig *)adUnitConfig
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
    if ([adObject conformsToProtocol:@protocol(PBMInterstitialAd)]) {
        id<PBMInterstitialAd> const eventHandler = (id<PBMInterstitialAd>)adObject;
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

// MARK: - InterstitialControllerLoadingDelegate

- (void)interstitialControllerDidLoadAd:(InterstitialController *)interstitialController {
    [self.flowDelegate adLoaderLoadedPrebidAd:self];
}

- (void)interstitialController:(InterstitialController *)interstitialController didFailWithError:(NSError *)error {
    [self.flowDelegate adLoader:self failedWithPrebidError:error];
}

// MARK: - InterstitialEventLoadingDelegate

- (void)prebidDidWin {
    [self.flowDelegate adLoaderDidWinPrebid:self];
}

- (void)adServerDidWin {
    [self.flowDelegate adLoader:self loadedPrimaryAd:self.delegate.eventHandler adSize:nil];
}

- (void)failedWithError:(nullable NSError *)error {
    [self.flowDelegate adLoader:self failedWithPrimarySDKError:error];
}

@synthesize reward;

@end
