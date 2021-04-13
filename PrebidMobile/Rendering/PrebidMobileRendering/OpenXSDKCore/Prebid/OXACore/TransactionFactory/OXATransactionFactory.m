//
//  OXATransactionFactory.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXATransactionFactory.h"

#import "OXAAdUnitConfig+Internal.h"
#import "OXABid.h"
#import "OXADisplayTransactionFactory.h"
#import "OXAVastTransactionFactory.h"
#import "OXMTransaction.h"

#import "OXMMacros.h"

@interface OXATransactionFactory()

@property (nonatomic, strong, readonly, nonnull) OXABid *bid;
@property (nonatomic, strong, readonly, nonnull) OXAAdUnitConfig *adConfiguration;
@property (nonatomic, strong, readonly, nonnull) id<OXMServerConnectionProtocol> connection;

// NOTE: need to call the completion callback only in the main thread
// use onFinishedWithTransaction
@property (nonatomic, copy, readonly, nonnull) OXATransactionFactoryCallback callback;

@property (nonatomic, strong, nullable) NSObject *currentFactory;

// Computed properties:
@property (nonatomic, readonly) BOOL isLoading;
@property (nonatomic, readonly, nonnull) OXATransactionFactoryCallback callbackForProperFactory;

@end



@implementation OXATransactionFactory

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
    
    if ([adMarkup containsString:@"<VAST"]) {
        return [self loadVASTTransaction:adMarkup];
    } else {
        return [self loadHTMLTransaction:adMarkup];
    }
}

// MARK: - Private Helpers

- (BOOL)isLoading {
    return (self.currentFactory != nil);
}

- (BOOL)loadHTMLTransaction:(NSString *)adMarkup {
    OXADisplayTransactionFactory * const factory = [[OXADisplayTransactionFactory alloc] initWithBid:self.bid
                                                                                     adConfiguration:self.adConfiguration
                                                                                          connection:self.connection
                                                                                            callback:self.callbackForProperFactory];
    self.currentFactory = factory;
    return [factory loadWithAdMarkup:adMarkup];
}

- (BOOL)loadVASTTransaction:(NSString *)adMarkup {
    OXAVastTransactionFactory * const factory = [[OXAVastTransactionFactory alloc] initWithConnection:self.connection
                                                                                      adConfiguration:self.adConfiguration.adConfiguration
                                                                                             callback:self.callbackForProperFactory];
    self.currentFactory = factory;
    return [factory loadWithAdMarkup:adMarkup];
}

- (OXATransactionFactoryCallback)callbackForProperFactory {
    @weakify(self);
    return ^(OXMTransaction * _Nullable transaction, NSError * _Nullable error) {
        @strongify(self);
        [self onFinishedWithTransaction:transaction error:error];
    };
}

- (void)onFinishedWithTransaction:(OXMTransaction *)transaction error:(NSError *)error {
    self.currentFactory = nil;
    if (self.bid.skadnInfo) {
        transaction.skadnetProductParameters = self.bid.skadnInfo;
    }
    self.callback(transaction, error);
}

@end
