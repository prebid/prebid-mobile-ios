//
//  PBMDisplayView.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <StoreKit/SKStoreProductViewController.h>

#import "PBMDisplayView.h"
#import "PBMDisplayView+InternalState.h"

#import "PBMAdUnitConfig.h"
#import "PBMAdUnitConfig+Internal.h"
#import "PBMBid.h"
#import "PBMTransactionFactory.h"
#import "PBMWinNotifier.h"
#import "PBMAdViewManager.h"
#import "PBMAdViewManagerDelegate.h"
#import "PBMInterstitialDisplayProperties.h"
#import "PBMModalManagerDelegate.h"
#import "PBMServerConnection.h"
#import "PBMServerConnectionProtocol.h"

#import "PBMMacros.h"

@interface PBMDisplayView () <PBMAdViewManagerDelegate, PBMModalManagerDelegate>

@property (nonatomic, strong, readonly, nonnull) PBMBid *bid;
@property (nonatomic, strong, readonly, nonnull) PBMAdUnitConfig *adConfiguration;

@property (nonatomic, strong, nullable) PBMTransactionFactory *transactionFactory;
@property (nonatomic, strong, nullable) PBMAdViewManager *adViewManager;

@property (nonatomic, strong, readonly, nonnull) PBMInterstitialDisplayProperties *interstitialDisplayProperties;

@end



@implementation PBMDisplayView

// MARK: - Public API
- (instancetype)initWithFrame:(CGRect)frame bid:(PBMBid *)bid configId:(NSString *)configId {
    return self = [self initWithFrame:frame bid:bid adConfiguration:[[PBMAdUnitConfig alloc] initWithConfigId:configId size:bid.size]];
}

- (instancetype)initWithFrame:(CGRect)frame bid:(PBMBid *)bid adConfiguration:(PBMAdUnitConfig *)adConfiguration {
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
                                                              connection:self.connection ?: [PBMServerConnection singleton]
                                                                callback:^(PBMTransaction * _Nullable transaction,
                                                                           NSError * _Nullable error) {
        @strongify(self);
        if (error) {
            [self reportFailureWithError:error];
        } else {
            [self displayTransaction:transaction];
        }
    }];
    [PBMWinNotifier notifyThroughConnection:[PBMServerConnection singleton]
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
    [self.interactionDelegate trackImpressionForDisplayView:self];
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
    [self.interactionDelegate didLeaveAppFromDisplayView:self];
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
    id<PBMDisplayViewInteractionDelegate> const delegate = self.interactionDelegate;
    if ([delegate respondsToSelector:@selector(displayViewWillPresentModal:)]) {
        [delegate displayViewWillPresentModal:self];
    }
}

- (void)modalManagerDidDismissModal {
    id<PBMDisplayViewInteractionDelegate> const delegate = self.interactionDelegate;
    if ([delegate respondsToSelector:@selector(displayViewDidDismissModal:)]) {
        [delegate displayViewDidDismissModal:self];
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
    id<PBMServerConnectionProtocol> const connection = self.connection ?: [PBMServerConnection singleton];
    self.adViewManager = [[PBMAdViewManager alloc] initWithConnection:connection modalManagerDelegate:self];
    self.adViewManager.adViewManagerDelegate = self;
    self.adViewManager.adConfiguration = self.adConfiguration.adConfiguration;
    if (self.adConfiguration.adFormat == PBMAdFormatVideo) {
        self.adConfiguration.adConfiguration.isBuiltInVideo = YES;
    }
    [self.adViewManager handleExternalTransaction:transaction];
}

@end
