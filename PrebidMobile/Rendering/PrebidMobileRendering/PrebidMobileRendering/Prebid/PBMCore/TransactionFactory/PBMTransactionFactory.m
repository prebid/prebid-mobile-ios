//
//  PBMTransactionFactory.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMTransactionFactory.h"

#import "PBMBid.h"
#import "PBMDisplayTransactionFactory.h"
#import "PBMVastTransactionFactory.h"
#import "PBMTransaction.h"

#import "PrebidMobileRenderingSwiftHeaders.h"
#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>

#import "PBMMacros.h"

@interface PBMTransactionFactory()

@property (nonatomic, strong, readonly, nonnull) PBMBid *bid;
@property (nonatomic, strong, readonly, nonnull) AdUnitConfig *adConfiguration;
@property (nonatomic, strong, readonly, nonnull) id<PBMServerConnectionProtocol> connection;

// NOTE: need to call the completion callback only in the main thread
// use onFinishedWithTransaction
@property (nonatomic, copy, readonly, nonnull) PBMTransactionFactoryCallback callback;

@property (nonatomic, strong, nullable) NSObject *currentFactory;

// Computed properties:
@property (nonatomic, readonly) BOOL isLoading;
@property (nonatomic, readonly, nonnull) PBMTransactionFactoryCallback callbackForProperFactory;

@end



@implementation PBMTransactionFactory

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
    PBMDisplayTransactionFactory * const factory = [[PBMDisplayTransactionFactory alloc] initWithBid:self.bid
                                                                                     adConfiguration:self.adConfiguration
                                                                                          connection:self.connection
                                                                                            callback:self.callbackForProperFactory];
    self.currentFactory = factory;
    return [factory loadWithAdMarkup:adMarkup];
}

- (BOOL)loadVASTTransaction:(NSString *)adMarkup {
    PBMVastTransactionFactory * const factory = [[PBMVastTransactionFactory alloc] initWithConnection:self.connection
                                                                                      adConfiguration:self.adConfiguration.adConfiguration
                                                                                             callback:self.callbackForProperFactory];
    self.currentFactory = factory;
    return [factory loadWithAdMarkup:adMarkup];
}

- (PBMTransactionFactoryCallback)callbackForProperFactory {
    @weakify(self);
    return ^(PBMTransaction * _Nullable transaction, NSError * _Nullable error) {
        @strongify(self);
        [self onFinishedWithTransaction:transaction error:error];
    };
}

- (void)onFinishedWithTransaction:(PBMTransaction *)transaction error:(NSError *)error {
    self.currentFactory = nil;
    if (self.bid.skadnInfo) {
        transaction.skadnetProductParameters = self.bid.skadnInfo;
    }
    self.callback(transaction, error);
}

@end
