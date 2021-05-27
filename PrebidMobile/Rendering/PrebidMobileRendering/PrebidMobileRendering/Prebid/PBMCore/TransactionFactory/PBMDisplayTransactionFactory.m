//
//  PBMDisplayTransactionFactory.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMDisplayTransactionFactory.h"

#import "PBMBid.h"
#import "PBMNativeFunctions.h"
#import "PBMCreativeModel.h"
#import "PBMLog.h"
#import "PBMTransaction.h"
#import "PBMTransactionDelegate.h"

#import "PBMMacros.h"

#import "PBMAdViewManagerDelegate.h"
#import "PBMDataAssetType.h"
#import "PBMPlayable.h"
#import "PBMJsonCodable.h"
#import "PBMNativeContextType.h"
#import "PBMNativeContextSubtype.h"
#import "PBMNativeEventType.h"
#import "PBMNativeEventTrackingMethod.h"
#import "PBMNativePlacementType.h"

#import "PBMBaseAdUnit.h"
#import "PBMBidRequesterFactoryBlock.h"
#import "PBMWinNotifierBlock.h"

#import "PBMImageAssetType.h"
#import "PBMNativeAdElementType.h"
#import "PBMAdFormatInternal.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

@interface PBMDisplayTransactionFactory() <PBMTransactionDelegate>

@property (nonatomic, strong, readonly, nonnull) PBMBid *bid;
@property (nonatomic, strong, readonly, nonnull) AdUnitConfig *adConfiguration;
@property (nonatomic, strong, readonly, nonnull) id<PBMServerConnectionProtocol> connection;

// NOTE: need to call the completion callback only in the main thread
// use onFinishedWithTransaction
@property (nonatomic, copy, readonly, nonnull) PBMTransactionFactoryCallback callback;

@property (nonatomic, strong, nullable) PBMTransaction *transaction;
@property (nonatomic, readonly) BOOL isLoading;

@end



@implementation PBMDisplayTransactionFactory

// MARK: - Public API

- (instancetype)initWithBid:(PBMBid *)bid
            adConfiguration:(AdUnitConfig *)adConfiguration
                 connection:(id<PBMServerConnectionProtocol>)connection
                   callback:(PBMTransactionFactoryCallback)callback
{
    if (!(self = [super init])) {
        return nil;
    }
    _bid = bid;
    _adConfiguration = adConfiguration;
    _connection = connection;
    _callback = [callback copy];
    return self;
}

- (BOOL)loadWithAdMarkup:(NSString *)adMarkup {
    if (self.isLoading) {
        return NO;
    }
    
    [self loadHTMLTransaction:adMarkup];
    
    return YES;
}

// MARK: - PBMTransactionDelegate protocol

- (void)transactionReadyForDisplay:(PBMTransaction *)transaction {
    self.transaction = nil;
    [self onFinishedWithTransaction:transaction error:nil];
}

- (void)transactionFailedToLoad:(PBMTransaction *)transaction error:(NSError *)error {
    self.transaction = nil;
    [self onFinishedWithTransaction:nil error:error];
}

// MARK: - Private Helpers

- (BOOL)isLoading {
    return (self.transaction != nil);
}

- (void)loadHTMLTransaction:(NSString *)adMarkup {
    NSMutableArray<PBMCreativeModel *> * const creativeModels = [[NSMutableArray alloc] init];

    [creativeModels addObject:[self htmlCreativeModelFromBid:self.bid
                                                    adMarkup:adMarkup
                                             adConfiguration:self.adConfiguration]];
    
    self.transaction = [[PBMTransaction alloc] initWithServerConnection:self.connection
                                                        adConfiguration:self.adConfiguration.adConfiguration
                                                                 models:creativeModels];
    self.transaction.delegate = self;
    self.transaction.skadnetProductParameters = self.bid.skadnInfo;
    [self.transaction startCreativeFactory];
}

- (PBMCreativeModel *)htmlCreativeModelFromBid:(PBMBid *)bid
                                      adMarkup:(NSString *)adMarkup
                               adConfiguration:(AdUnitConfig *)adConfiguration {
    PBMCreativeModel * const model = [[PBMCreativeModel alloc] init];
    NSString *html = nil;
    if (adConfiguration.adFormat != PBMAdFormatNativeInternal) {
        model.html = adMarkup;
    } else {
        if (adConfiguration.nativeAdConfiguration.nativeStylesCreative.length == 0) {
            PBMLogError(@"Native Styles creative string is empty.");
            model.html = @"";
        } else {
            html = [PBMNativeFunctions populateNativeAdTemplate:adConfiguration.nativeAdConfiguration.nativeStylesCreative
                                                  withTargeting:bid.targetingInfo
                                                          error:nil];
            model.html = html ?: @"";
        }
    }
    
    model.width = bid.size.width;
    model.height = bid.size.height;
    model.adConfiguration = adConfiguration.adConfiguration;
    return model;
}

- (void)onFinishedWithTransaction:(PBMTransaction *)transaction error:(NSError *)error {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.callback(transaction, error);
    });
}

@end
