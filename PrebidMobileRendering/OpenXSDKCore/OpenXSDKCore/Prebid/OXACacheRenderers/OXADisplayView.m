//
//  OXADisplayView.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <StoreKit/SKStoreProductViewController.h>

#import "OXADisplayView.h"
#import "OXADisplayView+InternalState.h"

#import "OXAAdUnitConfig.h"
#import "OXAAdUnitConfig+Internal.h"
#import "OXABid.h"
#import "OXATransactionFactory.h"
#import "OXAWinNotifier.h"
#import "OXMAdViewManager.h"
#import "OXMAdViewManagerDelegate.h"
#import "OXMInterstitialDisplayProperties.h"
#import "OXMModalManagerDelegate.h"
#import "OXMServerConnection.h"
#import "OXMServerConnectionProtocol.h"

#import "OXMMacros.h"

@interface OXADisplayView () <OXMAdViewManagerDelegate, OXMModalManagerDelegate>

@property (nonatomic, strong, readonly, nonnull) OXABid *bid;
@property (nonatomic, strong, readonly, nonnull) OXAAdUnitConfig *adConfiguration;

@property (nonatomic, strong, nullable) OXATransactionFactory *transactionFactory;
@property (nonatomic, strong, nullable) OXMAdViewManager *adViewManager;

@property (nonatomic, strong, readonly, nonnull) OXMInterstitialDisplayProperties *interstitialDisplayProperties;

@end



@implementation OXADisplayView

// MARK: - Public API
- (instancetype)initWithFrame:(CGRect)frame bid:(OXABid *)bid configId:(NSString *)configId {
    return self = [self initWithFrame:frame bid:bid adConfiguration:[[OXAAdUnitConfig alloc] initWithConfigId:configId size:bid.size]];
}

- (instancetype)initWithFrame:(CGRect)frame bid:(OXABid *)bid adConfiguration:(OXAAdUnitConfig *)adConfiguration {
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }
    _bid = bid;
    _adConfiguration = adConfiguration;
    _interstitialDisplayProperties = [[OXMInterstitialDisplayProperties alloc] init];
    return self;
}

- (void)displayAd {
    if (self.transactionFactory) {
        return;
    }
    
    @weakify(self);
    self.transactionFactory = [[OXATransactionFactory alloc] initWithBid:self.bid
                                                         adConfiguration:self.adConfiguration
                                                              connection:self.connection ?: [OXMServerConnection singleton]
                                                                callback:^(OXMTransaction * _Nullable transaction,
                                                                           NSError * _Nullable error) {
        @strongify(self);
        if (error) {
            [self reportFailureWithError:error];
        } else {
            [self displayTransaction:transaction];
        }
    }];
    [OXAWinNotifier notifyThroughConnection:[OXMServerConnection singleton]
                                 winningBid:self.bid
                                   callback:^(NSString *adMarkup) {
        @strongify(self);
        [self.transactionFactory loadWithAdMarkup:adMarkup];
    }];
}

- (BOOL)isCreativeOpened {
    return self.adViewManager.isCreativeOpened;
}

// MARK: - OXMAdViewManagerDelegate protocol

- (UIViewController *)viewControllerForModalPresentation {
    return [self.interactionDelegate viewControllerForModalPresentationFrom:self];
}

- (void)adLoaded:(OXMAdDetails *)oxmAdDetails {
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

// MARK: - OXMModalManagerDelegate

- (void)modalManagerWillPresentModal {
    id<OXADisplayViewInteractionDelegate> const delegate = self.interactionDelegate;
    if ([delegate respondsToSelector:@selector(displayViewWillPresentModal:)]) {
        [delegate displayViewWillPresentModal:self];
    }
}

- (void)modalManagerDidDismissModal {
    id<OXADisplayViewInteractionDelegate> const delegate = self.interactionDelegate;
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

- (void)displayTransaction:(OXMTransaction *)transaction {
    id<OXMServerConnectionProtocol> const connection = self.connection ?: [OXMServerConnection singleton];
    self.adViewManager = [[OXMAdViewManager alloc] initWithConnection:connection modalManagerDelegate:self];
    self.adViewManager.adViewManagerDelegate = self;
    self.adViewManager.adConfiguration = self.adConfiguration.adConfiguration;
    if (self.adConfiguration.adFormat == OXAAdFormatVideo) {
        self.adConfiguration.adConfiguration.isBuiltInVideo = YES;
    }
    [self.adViewManager handleExternalTransaction:transaction];
}

@end
