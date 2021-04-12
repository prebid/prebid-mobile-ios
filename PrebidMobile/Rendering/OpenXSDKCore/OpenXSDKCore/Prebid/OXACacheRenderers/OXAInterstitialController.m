//
//  OXAInterstitialController.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAInterstitialController.h"

#import "OXAAdUnitConfig.h"
#import "OXAAdUnitConfig+Internal.h"
#import "OXATransactionFactory.h"
#import "OXAWinNotifier.h"
#import "OXMAdViewManager.h"
#import "OXMAdViewManagerDelegate.h"
#import "OXMInterstitialDisplayProperties.h"
#import "OXMMacros.h"
#import "OXMServerConnection.h"
#import "OXMServerConnectionProtocol.h"

@interface OXAInterstitialController () <OXMAdViewManagerDelegate>

@property (nonatomic, strong, readonly, nonnull) OXABid *bid;
@property (nonatomic, strong, readonly, nonnull) OXAAdUnitConfig *adConfiguration;

@property (nonatomic, strong, readonly, nullable) id<OXMServerConnectionProtocol> connection;

@property (nonatomic, strong, nullable) OXATransactionFactory *transactionFactory;
@property (nonatomic, strong, nullable) OXMAdViewManager *adViewManager;

@property (nonatomic, strong, readonly, nonnull) OXMInterstitialDisplayProperties *interstitialDisplayProperties;

@end

@implementation OXAInterstitialController

// MARK: - Public API

- (instancetype)initWithBid:(OXABid *)bid configId:(NSString *)configId {
    OXAAdUnitConfig *adConfig = [[OXAAdUnitConfig alloc] initWithConfigId:configId];
    adConfig.isInterstitial = YES;
    return self = [self initWithBid:bid adConfiguration:adConfig];
}

- (instancetype)initWithBid:(OXABid *)bid adConfiguration:(OXAAdUnitConfig *)adConfiguration {
    if (!(self = [super init])) {
        return nil;
    }
    _bid = bid;
    _adConfiguration = adConfiguration;
    _interstitialDisplayProperties = [[OXMInterstitialDisplayProperties alloc] init];
    return self;
}

- (OXAAdFormat)adFormat {
    return self.adConfiguration.adFormat;
}

- (void)setAdFormat:(OXAAdFormat)adFormat {
    self.adConfiguration.adFormat = adFormat;
}

-(BOOL)isOptIn {
    return self.adConfiguration.isOptIn;
}

-(void)setIsOptIn:(BOOL) newValue {
    self.adConfiguration.isOptIn = newValue;
}

- (void)loadAd {
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

- (void)show {
    [self.adViewManager show];
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
    id<OXAInterstitialControllerInteractionDelegate> const delegate = self.interactionDelegate;
    if ([delegate respondsToSelector:@selector(interstitialControllerDidComplete:)]) {
        [delegate interstitialControllerDidComplete:self];
    }
}

- (void)adDidDisplay {
    id<OXAInterstitialControllerInteractionDelegate> const delegate = self.interactionDelegate;
    if ([delegate respondsToSelector:@selector(interstitialControllerDidDisplay:)]) {
        [delegate interstitialControllerDidDisplay:self];
    }
}

- (void)adWasClicked {
    [self.interactionDelegate interstitialControllerDidClickAd:self];
}

- (void)adViewWasClicked {
    [self.interactionDelegate interstitialControllerDidClickAd:self];
}

- (void)adDidExpand {
    // nop?
}

- (void)adDidCollapse {
    // nop?
}

- (void)adDidLeaveApp {
    [self.interactionDelegate interstitialControllerDidLeaveApp:self];
}

- (void)adClickthroughDidClose {
    // nop?
}

- (void)adDidClose {
    self.adViewManager = nil;
    [self.interactionDelegate interstitialControllerDidCloseAd:self];
}

// MARK: - Private Helpers

- (void)reportFailureWithError:(NSError *)error {
    self.transactionFactory = nil;
    [self.loadingDelegate interstitialController:self didFailWithError:error];
}

- (void)reportSuccess {
    self.transactionFactory = nil;
    [self.loadingDelegate interstitialControllerDidLoadAd:self];
}

- (void)displayTransaction:(OXMTransaction *)transaction {
    id<OXMServerConnectionProtocol> const connection = self.connection ?: [OXMServerConnection singleton];
    self.adViewManager = [[OXMAdViewManager alloc] initWithConnection:connection modalManagerDelegate:nil];
    self.adViewManager.adViewManagerDelegate = self;
    self.adViewManager.adConfiguration.isInterstitialAd = YES;
    self.adViewManager.adConfiguration.isOptIn = self.adConfiguration.isOptIn;
    [self.adViewManager handleExternalTransaction:transaction];
}

@end
