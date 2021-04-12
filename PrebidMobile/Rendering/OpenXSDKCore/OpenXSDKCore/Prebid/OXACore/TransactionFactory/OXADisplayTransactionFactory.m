//
//  OXADisplayTransactionFactory.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXADisplayTransactionFactory.h"

#import "OXABid.h"
#import "OXANativeAdConfiguration.h"
#import "OXANativeFunctions.h"
#import "OXAAdUnitConfig+Internal.h"
#import "OXMCreativeModel.h"
#import "OXMLog.h"
#import "OXMTransaction.h"
#import "OXMTransactionDelegate.h"

#import "OXMMacros.h"



@interface OXADisplayTransactionFactory() <OXMTransactionDelegate>

@property (nonatomic, strong, readonly, nonnull) OXABid *bid;
@property (nonatomic, strong, readonly, nonnull) OXAAdUnitConfig *adConfiguration;
@property (nonatomic, strong, readonly, nonnull) id<OXMServerConnectionProtocol> connection;

// NOTE: need to call the completion callback only in the main thread
// use onFinishedWithTransaction
@property (nonatomic, copy, readonly, nonnull) OXATransactionFactoryCallback callback;

@property (nonatomic, strong, nullable) OXMTransaction *transaction;
@property (nonatomic, readonly) BOOL isLoading;

@end



@implementation OXADisplayTransactionFactory

// MARK: - Public API

- (instancetype)initWithBid:(OXABid *)bid
            adConfiguration:(OXAAdUnitConfig *)adConfiguration
                 connection:(id<OXMServerConnectionProtocol>)connection
                   callback:(OXATransactionFactoryCallback)callback
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

// MARK: - OXMTransactionDelegate protocol

- (void)transactionReadyForDisplay:(OXMTransaction *)transaction {
    self.transaction = nil;
    [self onFinishedWithTransaction:transaction error:nil];
}

- (void)transactionFailedToLoad:(OXMTransaction *)transaction error:(NSError *)error {
    self.transaction = nil;
    [self onFinishedWithTransaction:nil error:error];
}

// MARK: - Private Helpers

- (BOOL)isLoading {
    return (self.transaction != nil);
}

- (void)loadHTMLTransaction:(NSString *)adMarkup {
    NSMutableArray<OXMCreativeModel *> * const creativeModels = [[NSMutableArray alloc] init];

    [creativeModels addObject:[self htmlCreativeModelFromBid:self.bid
                                                    adMarkup:adMarkup
                                             adConfiguration:self.adConfiguration]];
    
    self.transaction = [[OXMTransaction alloc] initWithServerConnection:self.connection
                                                        adConfiguration:self.adConfiguration.adConfiguration
                                                                 models:creativeModels];
    self.transaction.delegate = self;
    self.transaction.skadnetProductParameters = self.bid.skadnInfo;
    [self.transaction startCreativeFactory];
}

- (OXMCreativeModel *)htmlCreativeModelFromBid:(OXABid *)bid
                                      adMarkup:(NSString *)adMarkup
                               adConfiguration:(OXAAdUnitConfig *)adConfiguration {
    OXMCreativeModel * const model = [[OXMCreativeModel alloc] init];
    NSString *html = nil;
    if (adConfiguration.adFormat != OXMAdFormatNative) {
        model.html = adMarkup;
    } else {
        if (adConfiguration.nativeAdConfig.nativeStylesCreative.length == 0) {
            OXMLogError(@"Native Styles creative string is empty.");
            model.html = @"";
        } else {
            html = [OXANativeFunctions populateNativeAdTemplate:adConfiguration.nativeAdConfig.nativeStylesCreative
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

- (void)onFinishedWithTransaction:(OXMTransaction *)transaction error:(NSError *)error {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.callback(transaction, error);
    });
}

@end
