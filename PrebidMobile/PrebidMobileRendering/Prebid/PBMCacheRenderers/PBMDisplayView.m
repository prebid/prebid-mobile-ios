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

#import <StoreKit/SKStoreProductViewController.h>

#import "PBMDisplayView.h"
#import "PBMDisplayView+InternalState.h"

#import "PBMTransactionFactory.h"
#import "PBMWinNotifier.h"
#import "PBMAdViewManager.h"
#import "PBMAdViewManagerDelegate.h"
#import "PBMInterstitialDisplayProperties.h"
#import "PBMModalManagerDelegate.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#import "PBMMacros.h"

@interface PBMDisplayView () <PBMAdViewManagerDelegate, PBMModalManagerDelegate, PBMThirdPartyAdViewLoader>

@property (nonatomic, strong, readonly, nonnull) Bid *bid;
@property (nonatomic, strong, readonly, nonnull) AdUnitConfig *adConfiguration;

@property (nonatomic, strong, nullable) PBMAdViewManager *adViewManager;

@property (nonatomic, strong, readonly, nonnull) PBMInterstitialDisplayProperties *interstitialDisplayProperties;

@property (nonatomic, strong, nullable) id<PrebidMobilePluginRenderer> renderer;

@end

@implementation PBMDisplayView

// MARK: - Public API
- (instancetype)initWithFrame:(CGRect)frame bid:(Bid *)bid configId:(NSString *)configId {
    return self = [self initWithFrame:frame bid:bid adConfiguration:[[AdUnitConfig alloc] initWithConfigId:configId size:bid.size]];
}

- (instancetype)initWithFrame:(CGRect)frame bid:(Bid *)bid adConfiguration:(AdUnitConfig *)adConfiguration {
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }
    _bid = bid;
    _adConfiguration = adConfiguration;
    _interstitialDisplayProperties = [[PBMInterstitialDisplayProperties alloc] init];
    return self;
}

- (void)displayAd {
    self.renderer = [[PrebidMobilePluginRegister shared] getPluginForPreferredRendererWithBid:self.bid];

    NSLog(@"Renderer: %@", self.renderer);
    self.adConfiguration.adConfiguration.winningBidAdFormat = self.bid.adFormat;
    id<PrebidServerConnectionProtocol> const connection = self.connection ?: PrebidServerConnection.shared;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.renderer createBannerAdViewWith:self.frame bid:self.bid adConfiguration:self.adConfiguration connection:connection adViewDelegate:self];
    });
}

- (BOOL)isCreativeOpened {
    return self.adViewManager.isCreativeOpened;
}

// MARK: - PBMAdViewManagerDelegate protocol

- (UIViewController *)viewControllerForModalPresentation {
    return [self.interactionDelegate viewControllerForModalPresentationFromDisplayView:self];
}

- (void)adLoaded:(PBMAdDetails *)pbmAdDetails {
    [self reportSuccess];
}

- (void)failedToLoad:(NSError *)error {
    [self reportFailureWithError:error];
}

- (void)adDidComplete {
    // nop?
    // Note: modal handled in `displayViewDidDismissModal`
}

- (void)adDidDisplay {
    [self.interactionDelegate trackImpressionForDisplayView:self];
}

- (void)adWasClicked {
    [self interactionDelegateWillPresentModal];
}

- (void)adViewWasClicked {
    // nop?
    // Note: modal handled in `modalManagerWillPresentModal`
}

- (void)adDidExpand {
    // nop?
    // Note: modal handled in `modalManagerWillPresentModal`
}

- (void)adDidCollapse {
    // nop?
    // Note: modal handled in `displayViewDidDismissModal`
}

- (void)adDidLeaveApp {
    [self.interactionDelegate didLeaveAppFrom:self];
}

- (void)adClickthroughDidClose {
    [self interactionDelegateDidDismissModal];
}

- (void)adDidClose {
    // nop?
    // Note: modal handled in `displayViewDidDismissModal`
}

- (UIView *)displayView {
    return self;
}

// MARK: - PBMModalManagerDelegate

- (void)modalManagerWillPresentModal {
    [self interactionDelegateWillPresentModal];
}

- (void)modalManagerDidDismissModal {
    [self interactionDelegateDidDismissModal];
}

// MARK: - Private Helpers

- (void)reportFailureWithError:(NSError *)error {
    [self.loadingDelegate displayView:self didFailWithError:error];
}

- (void)reportSuccess {
    [self.loadingDelegate displayViewDidLoadAd:self];
}

- (void)interactionDelegateWillPresentModal {
    NSObject<DisplayViewInteractionDelegate> const *delegate = self.interactionDelegate;
    if ([delegate respondsToSelector:@selector(willPresentModalFrom:)]) {
        [delegate willPresentModalFrom:self];
    }
}

- (void)interactionDelegateDidDismissModal {
    NSObject<DisplayViewInteractionDelegate> const *delegate = self.interactionDelegate;
    if ([delegate respondsToSelector:@selector(didDismissModalFrom:)]) {
        [delegate didDismissModalFrom:self];
    }
}

@end
