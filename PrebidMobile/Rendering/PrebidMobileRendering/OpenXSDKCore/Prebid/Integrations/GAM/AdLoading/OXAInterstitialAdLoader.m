//
//  OXAInterstitialAdLoader.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAInterstitialAdLoader.h"

#import "OXAAdLoaderFlowDelegate.h"
#import "OXAInterstitialEventHandler.h"
#import "OXAInterstitialController.h"
#import "OXAInterstitialControllerLoadingDelegate.h"

#import "OXMMacros.h"

@interface OXAInterstitialAdLoader () <OXAInterstitialControllerLoadingDelegate>
@property (nonatomic, weak, nullable, readonly) id<OXAInterstitialAdLoaderDelegate> delegate;
@end



@implementation OXAInterstitialAdLoader

@synthesize flowDelegate = _flowDelegate;

// MARK: - Lifecycle

- (instancetype)initWithDelegate:(id<OXAInterstitialAdLoaderDelegate>)delegate {
    if (!(self = [super init])) {
        return nil;
    }
    _delegate = delegate;
    return self;
}

// MARK: - OXAAdLoaderProtocol

- (id<OXAPrimaryAdRequesterProtocol>)primaryAdRequester {
    return self.delegate.eventHandler;
}

- (void)createApolloAdWithBid:(OXABid *)bid
                 adUnitConfig:(OXAAdUnitConfig *)adUnitConfig
                adObjectSaver:(void (^)(id))adObjectSaver
            loadMethodInvoker:(void (^)(dispatch_block_t))loadMethodInvoker
{
    OXAInterstitialController * const controller = [[OXAInterstitialController alloc] initWithBid:bid
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
    if ([adObject isKindOfClass:[OXAInterstitialController class]]) {
        OXAInterstitialController * const controller = (OXAInterstitialController *)adObject;
        [self.delegate interstitialAdLoader:self
                                   loadedAd:^(UIViewController *targetController) {
            [controller show];
        } isReadyBlock:^BOOL{
            return YES;
        }];
        return;
    }
    if ([adObject conformsToProtocol:@protocol(OXAInterstitialEventHandler)]) {
        id<OXAInterstitialEventHandler> const eventHandler = (id<OXAInterstitialEventHandler>)adObject;
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
                           isReadyBlock:^BOOL{ return NO; }];
}

// MARK: - OXAInterstitialControllerLoadingDelegate

- (void)interstitialControllerDidLoadAd:(OXAInterstitialController *)interstitialController {
    [self.flowDelegate adLoaderLoadedApolloAd:self];
}

- (void)interstitialController:(OXAInterstitialController *)interstitialController didFailWithError:(NSError *)error {
    [self.flowDelegate adLoader:self failedWithApolloError:error];
}

// MARK: - OXAInterstitialEventLoadingDelegate

- (void)apolloDidWin {
    [self.flowDelegate adLoaderDidWinApollo:self];
}

- (void)adServerDidWin {
    [self.flowDelegate adLoader:self loadedPrimaryAd:self.delegate.eventHandler adSize:nil];
}

- (void)failedWithError:(nullable NSError *)error {
    [self.flowDelegate adLoader:self failedWithPrimarySDKError:error];
}

// MARK: - OXARewardedEventLoadingDelegate

- (NSObject *)reward {
    id<OXAInterstitialAdLoaderDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(reward)]) {
        return [delegate reward];
    }
    return nil;
}

- (void)setReward:(NSObject *)reward {
    id<OXAInterstitialAdLoaderDelegate> const delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(setReward:)]) {
        return [delegate setReward:reward];
    }
}

@end
