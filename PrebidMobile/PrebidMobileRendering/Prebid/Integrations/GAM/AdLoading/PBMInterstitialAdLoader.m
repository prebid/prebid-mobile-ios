/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMInterstitialAdLoader.h"

#import "PBMAdLoaderFlowDelegate.h"
#import "PBMInterstitialEventHandler.h"
#import "PBMInterstitialAdLoaderDelegate.h"

#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@interface PBMInterstitialAdLoader () <InterstitialControllerLoadingDelegate, InterstitialEventLoadingDelegate>

@property (nonatomic, weak, nullable, readonly) id<PBMInterstitialAdLoaderDelegate, InterstitialControllerInteractionDelegate> delegate;
@property (nonatomic, weak, nullable, readonly) id<PBMPrimaryAdRequesterProtocol> eventHandler;

@end

@implementation PBMInterstitialAdLoader

@synthesize flowDelegate = _flowDelegate;

// MARK: - Lifecycle

- (instancetype)initWithDelegate:(id<PBMInterstitialAdLoaderDelegate, InterstitialControllerInteractionDelegate>)delegate
                    eventHandler:(nonnull id<PBMPrimaryAdRequesterProtocol>)eventHandler  {
    if (!(self = [super init])) {
        return nil;
    }
    
    _delegate = delegate;
    _eventHandler = eventHandler;
    
    return self;
}

// MARK: - PBMAdLoaderProtocol

- (id<PBMPrimaryAdRequesterProtocol>)primaryAdRequester {
    return self.eventHandler;
}

- (void)createPrebidAdWithBid:(Bid *)bid
                 adUnitConfig:(AdUnitConfig *)adUnitConfig
                adObjectSaver:(void (^)(id))adObjectSaver
            loadMethodInvoker:(void (^)(dispatch_block_t))loadMethodInvoker {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (!self) { return; }
        
        id<PrebidMobileInterstitialControllerProtocol> controller = [self createInterstitialControllerWithBid:bid
                                                                                                 adUnitConfig:adUnitConfig];
        adObjectSaver(controller);
        
        loadMethodInvoker(^{
            [controller loadAd];
        });
    });
}

- (void)reportSuccessWithAdObject:(id)adObject adSize:(nullable NSValue *)adSize {
    if ([adObject conformsToProtocol:@protocol(PrebidMobileInterstitialControllerProtocol)]) {
        id<PrebidMobileInterstitialControllerProtocol> controller = (id<PrebidMobileInterstitialControllerProtocol>)adObject;
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

- (void)interstitialControllerDidLoadAd:(id<PrebidMobileInterstitialControllerProtocol>)interstitialController {
    [self.flowDelegate adLoaderLoadedPrebidAd:self];
}

- (void)interstitialController:(id<PrebidMobileInterstitialControllerProtocol>)interstitialController
              didFailWithError:(NSError *)error {
    [self.flowDelegate adLoader:self failedWithPrebidError:error];
}

// MARK: - InterstitialEventLoadingDelegate

- (void)prebidDidWin {
    [self.flowDelegate adLoaderDidWinPrebid:self];
}

- (void)adServerDidWin {
    [self.flowDelegate adLoader:self loadedPrimaryAd:self.eventHandler adSize:nil];
}

- (void)failedWithError:(nullable NSError *)error {
    [self.flowDelegate adLoader:self failedWithPrimarySDKError:error];
}

- (id<PrebidMobileInterstitialControllerProtocol>)createInterstitialControllerWithBid:(Bid *)bid
                                                                         adUnitConfig:(AdUnitConfig *)adUnitConfig {
    id<PrebidMobilePluginRenderer> renderer = [[PrebidMobilePluginRegister shared] getPluginForPreferredRendererWithBid:bid];
    PBMLogInfo(@"Renderer: %@", renderer);
    
    id<PrebidMobileInterstitialControllerProtocol> controller = [renderer createInterstitialControllerWithBid:bid
                                                                                              adConfiguration:adUnitConfig
                                                                                              loadingDelegate:self
                                                                                          interactionDelegate:self.delegate];
    
    if (controller) {
        return controller;
    }
    
    PBMLogWarn(@"SDK couldn't retrieve an implementation of PrebidMobileInterstitialControllerProtocol. SDK will use the PrebidMobile SDK renderer.");
    
    id<PrebidMobilePluginRenderer> sdkRenderer = PrebidMobilePluginRegister.shared.sdkRenderer;
    return [sdkRenderer createInterstitialControllerWithBid:bid
                                            adConfiguration:adUnitConfig
                                            loadingDelegate:self
                                        interactionDelegate:self.delegate];
}

@end
