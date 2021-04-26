//
//  PBMInterstitialController.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMInterstitialController.h"

#import "PBMAdUnitConfig.h"
#import "PBMAdUnitConfig+Internal.h"
#import "PBMTransactionFactory.h"
#import "PBMWinNotifier.h"
#import "PBMAdViewManager.h"
#import "PBMAdViewManagerDelegate.h"
#import "PBMInterstitialDisplayProperties.h"
#import "PBMMacros.h"
#import "PBMServerConnection.h"
#import "PBMServerConnectionProtocol.h"

@interface PBMInterstitialController () <PBMAdViewManagerDelegate>

@property (nonatomic, strong, readonly, nonnull) PBMBid *bid;
@property (nonatomic, strong, readonly, nonnull) PBMAdUnitConfig *adConfiguration;

@property (nonatomic, strong, readonly, nullable) id<PBMServerConnectionProtocol> connection;

@property (nonatomic, strong, nullable) PBMTransactionFactory *transactionFactory;
@property (nonatomic, strong, nullable) PBMAdViewManager *adViewManager;

@property (nonatomic, strong, readonly, nonnull) PBMInterstitialDisplayProperties *interstitialDisplayProperties;

@end

@implementation PBMInterstitialController

// MARK: - Public API

- (instancetype)initWithBid:(PBMBid *)bid configId:(NSString *)configId {
    PBMAdUnitConfig *adConfig = [[PBMAdUnitConfig alloc] initWithConfigId:configId];
    adConfig.isInterstitial = YES;
    return self = [self initWithBid:bid adConfiguration:adConfig];
}

- (instancetype)initWithBid:(PBMBid *)bid adConfiguration:(PBMAdUnitConfig *)adConfiguration {
    if (!(self = [super init])) {
        return nil;
    }
    _bid = bid;
    _adConfiguration = adConfiguration;
    _interstitialDisplayProperties = [[PBMInterstitialDisplayProperties alloc] init];
    return self;
}

- (PBMAdFormat)adFormat {
    return self.adConfiguration.adFormat;
}

- (void)setAdFormat:(PBMAdFormat)adFormat {
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

- (void)show {
    [self.adViewManager show];
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
    id<PBMInterstitialControllerInteractionDelegate> const delegate = self.interactionDelegate;
    if ([delegate respondsToSelector:@selector(interstitialControllerDidComplete:)]) {
        [delegate interstitialControllerDidComplete:self];
    }
}

- (void)adDidDisplay {
    id<PBMInterstitialControllerInteractionDelegate> const delegate = self.interactionDelegate;
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

- (void)displayTransaction:(PBMTransaction *)transaction {
    id<PBMServerConnectionProtocol> const connection = self.connection ?: [PBMServerConnection singleton];
    self.adViewManager = [[PBMAdViewManager alloc] initWithConnection:connection modalManagerDelegate:nil];
    self.adViewManager.adViewManagerDelegate = self;
    self.adViewManager.adConfiguration.isInterstitialAd = YES;
    self.adViewManager.adConfiguration.isOptIn = self.adConfiguration.isOptIn;
    [self.adViewManager handleExternalTransaction:transaction];
}

@end
