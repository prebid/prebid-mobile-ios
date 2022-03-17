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
#import "PBMServerConnection.h"
#import "PBMServerConnectionProtocol.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

#import "PBMMacros.h"

@interface PBMDisplayView () <PBMAdViewManagerDelegate, PBMModalManagerDelegate>

@property (nonatomic, strong, readonly, nonnull) Bid *bid;
@property (nonatomic, strong, readonly, nonnull) AdUnitConfig *adConfiguration;

@property (nonatomic, strong, nullable) PBMTransactionFactory *transactionFactory;
@property (nonatomic, strong, nullable) PBMAdViewManager *adViewManager;

@property (nonatomic, strong, readonly, nonnull) PBMInterstitialDisplayProperties *interstitialDisplayProperties;

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
    if (self.transactionFactory) {
        return;
    }
    
    @weakify(self);
    self.transactionFactory = [[PBMTransactionFactory alloc] initWithBid:self.bid
                                                         adConfiguration:self.adConfiguration
                                                              connection:self.connection ?: PBMServerConnection.shared
                                                                callback:^(PBMTransaction * _Nullable transaction,
                                                                           NSError * _Nullable error) {
        @strongify(self);
        if (error) {
            [self reportFailureWithError:error];
        } else {
            [self displayTransaction:transaction];
        }
    }];
    [PBMWinNotifier notifyThroughConnection:PBMServerConnection.shared
                                 winningBid:self.bid
                                   callback:^(NSString *adMarkup) {
        @strongify(self);
        [self.transactionFactory loadWithAdMarkup:adMarkup];
    }];
}

- (BOOL)isCreativeOpened {
    return self.adViewManager.isCreativeOpened;
}

// MARK: - PBMAdViewManagerDelegate protocol

- (UIViewController *)viewControllerForModalPresentation {
    return [self.interactionDelegate viewControllerForModalPresentationFrom:self];
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
    [self.interactionDelegate trackImpressionFor:self];
}

- (void)adWasClicked {
    // nop?
    // Note: modal handled in `modalManagerWillPresentModal`
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
    // nop?
    // Note: modal handled in `displayViewDidDismissModal`
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
    NSObject<DisplayViewInteractionDelegate> const *delegate = self.interactionDelegate;
    if ([delegate respondsToSelector:@selector(willPresentModalFrom:)]) {
        [delegate willPresentModalFrom:self];
    }
}

- (void)modalManagerDidDismissModal {
    NSObject<DisplayViewInteractionDelegate> const *delegate = self.interactionDelegate;
    if ([delegate respondsToSelector:@selector(didDismissModalFrom:)]) {
        [delegate didDismissModalFrom:self];
    }
}

// MARK: - Private Helpers

- (void)reportFailureWithError:(NSError *)error {
    self.transactionFactory = nil;
    [self.loadingDelegate displayView:self didFailWithError:error];
}

- (void)reportSuccess {
    self.transactionFactory = nil;
    [self.loadingDelegate displayViewDidLoadAd:self];
}

- (void)displayTransaction:(PBMTransaction *)transaction {
    id<PBMServerConnectionProtocol> const connection = self.connection ?: PBMServerConnection.shared;
    self.adViewManager = [[PBMAdViewManager alloc] initWithConnection:connection modalManagerDelegate:self];
    self.adViewManager.adViewManagerDelegate = self;
    self.adViewManager.adConfiguration = self.adConfiguration.adConfiguration;
    if ([self.adConfiguration.adFormats containsObject:AdFormat.video]) {
        self.adConfiguration.adConfiguration.isBuiltInVideo = YES;
    }
    [self.adViewManager handleExternalTransaction:transaction];
}

@end
