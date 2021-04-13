//
//  OXAVastTransactionFactory.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAVastTransactionFactory.h"

#import "OXMAdLoadManagerVAST.h"

#import "OXMMacros.h"


@interface OXAVastTransactionFactory() <OXMAdLoadManagerDelegate>

@property (nonatomic, strong, readonly, nonnull) id<OXMServerConnectionProtocol> connection;
@property (nonatomic, strong, readonly, nonnull) OXMAdConfiguration *adConfiguration;

// NOTE: need to call the completion callback only in the main thread
// use onFinishedWithTransaction
@property (nonatomic, copy, readonly, nonnull) OXATransactionFactoryCallback callback;

@property (nonatomic, strong, nullable) OXMAdLoadManagerVAST *vastLoadManager;
@property (nonatomic, readonly) BOOL isLoading;

@end



@implementation OXAVastTransactionFactory

// MARK: - Public API

- (instancetype)initWithConnection:(id<OXMServerConnectionProtocol>)connection
                   adConfiguration:(OXMAdConfiguration *)adConfiguration
                          callback:(OXATransactionFactoryCallback)callback
{
    if (!(self = [super init])) {
        return nil;
    }
    _adConfiguration = adConfiguration;
    _connection = connection;
    _callback = [callback copy];
    return self;
}

- (BOOL)loadWithAdMarkup:(NSString *)adMarkup {
    if (self.isLoading) {
        return NO;
    }
    
    return [self loadVASTTransaction:adMarkup];
}

// MARK: - OXMAdLoadManagerDelegate protocol

- (void)loadManager:(id<OXMAdLoadManagerProtocol>)loadManager didLoadTransaction:(OXMTransaction *)transaction {
    [self onFinishedWithTransaction:transaction error:nil];
}

- (void)loadManager:(id<OXMAdLoadManagerProtocol>)loadManager failedToLoadTransaction:(OXMTransaction *)transaction
              error:(NSError *)error
{
    [self onFinishedWithTransaction:nil error:error];
}

// MARK: - Private Helpers

- (BOOL)isLoading {
    return (self.vastLoadManager != nil);
}

- (BOOL)loadVASTTransaction:(NSString *)adMarkup {
    self.vastLoadManager = [[OXMAdLoadManagerVAST alloc] initWithConnection:self.connection
                                                            adConfiguration:self.adConfiguration];
    self.vastLoadManager.adLoadManagerDelegate = self;
    [self.vastLoadManager loadFromString:adMarkup];
    return YES;
}

- (void)onFinishedWithTransaction:(OXMTransaction *)transaction error:(NSError *)error {
    self.vastLoadManager = nil;
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.callback(transaction, error);
    });
}

@end
