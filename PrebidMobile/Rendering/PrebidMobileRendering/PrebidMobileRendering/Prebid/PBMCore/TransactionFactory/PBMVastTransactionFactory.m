//
//  PBMVastTransactionFactory.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMVastTransactionFactory.h"

#import "PBMAdLoadManagerVAST.h"

#import "PBMMacros.h"


@interface PBMVastTransactionFactory() <PBMAdLoadManagerDelegate>

@property (nonatomic, strong, readonly, nonnull) id<PBMServerConnectionProtocol> connection;
@property (nonatomic, strong, readonly, nonnull) PBMAdConfiguration *adConfiguration;

// NOTE: need to call the completion callback only in the main thread
// use onFinishedWithTransaction
@property (nonatomic, copy, readonly, nonnull) PBMTransactionFactoryCallback callback;

@property (nonatomic, strong, nullable) PBMAdLoadManagerVAST *vastLoadManager;
@property (nonatomic, readonly) BOOL isLoading;

@end



@implementation PBMVastTransactionFactory

// MARK: - Public API

- (instancetype)initWithConnection:(id<PBMServerConnectionProtocol>)connection
                   adConfiguration:(PBMAdConfiguration *)adConfiguration
                          callback:(PBMTransactionFactoryCallback)callback
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

// MARK: - PBMAdLoadManagerDelegate protocol

- (void)loadManager:(id<PBMAdLoadManagerProtocol>)loadManager didLoadTransaction:(PBMTransaction *)transaction {
    [self onFinishedWithTransaction:transaction error:nil];
}

- (void)loadManager:(id<PBMAdLoadManagerProtocol>)loadManager failedToLoadTransaction:(PBMTransaction *)transaction
              error:(NSError *)error
{
    [self onFinishedWithTransaction:nil error:error];
}

// MARK: - Private Helpers

- (BOOL)isLoading {
    return (self.vastLoadManager != nil);
}

- (BOOL)loadVASTTransaction:(NSString *)adMarkup {
    self.vastLoadManager = [[PBMAdLoadManagerVAST alloc] initWithConnection:self.connection
                                                            adConfiguration:self.adConfiguration];
    self.vastLoadManager.adLoadManagerDelegate = self;
    [self.vastLoadManager loadFromString:adMarkup];
    return YES;
}

- (void)onFinishedWithTransaction:(PBMTransaction *)transaction error:(NSError *)error {
    self.vastLoadManager = nil;
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.callback(transaction, error);
    });
}

@end
