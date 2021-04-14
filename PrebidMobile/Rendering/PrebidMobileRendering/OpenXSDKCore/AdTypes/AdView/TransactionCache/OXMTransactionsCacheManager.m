//
//  OXMTransactionsCacheManager.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMAdConfiguration.h"
#import "OXMTransactionsCacheManager.h"
#import "OXMAdLoadManagerFactory.h"
#import "OXMAdLoadManagerProtocol.h"
#import "OXMTransaction.h"
#import "OXMTransactionsCache.h"
#import "OXMFunctions+Private.h"
#import "OXMLog.h"

#pragma mark - Private Category

@interface OXMTransactionsCacheManager ()

@property (nonatomic, strong) OXMVoidBlock preloadingCompletedBlock;

@property (nonatomic, assign) OXMTransactionsCache* transactionsCache;
@property (nonatomic, strong) NSMutableArray<id<OXMAdLoadManagerProtocol>> *loaders;

@end

#pragma mark - Implementation

@implementation OXMTransactionsCacheManager

- (instancetype)initWithTransactionsCache:(OXMTransactionsCache *)transactionsCache {
    self = [super init];
    if (self) {
        self.transactionsCache = transactionsCache;
        self.loaders = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - OXMAdLoadManagerDelegate

- (void)loadManager:(id<OXMAdLoadManagerProtocol>)loadManager didLoadTransaction:(OXMTransaction *)transaction {
    [self.transactionsCache addTransaction:transaction];
    
    [self dismissLoadManager:loadManager];
}

- (void)loadManager:(id<OXMAdLoadManagerProtocol>)loadManager failedToLoadTransaction:(OXMTransaction *) transaction error:(NSError *) error {
    OXMLogError(@"Failed to preload video ad with error: %@", [error localizedDescription]);
    
    [self dismissLoadManager:loadManager];
}

#pragma mark - Public Methods

- (void)preloadAdsWithConfigurations:(NSArray<OXMAdConfiguration *> *)configurations
          serverConnection:(id<OXMServerConnectionProtocol>)serverConnection
                completion:(OXMVoidBlock)completion {
    self.preloadingCompletedBlock = completion;
    [configurations enumerateObjectsUsingBlock:^(OXMAdConfiguration *config, NSUInteger idx, BOOL *stop) {
        [self preloadAdWithConfiguration:config withServerConnection:serverConnection];
    }];
}

- (void)preloadAdWithConfiguration:(OXMAdConfiguration *)adConfiguration
                  serverConnection:(id<OXMServerConnectionProtocol>)serverConnection
                        completion:(OXMVoidBlock)completion {
    self.preloadingCompletedBlock = completion;

    [self preloadAdWithConfiguration:adConfiguration withServerConnection:serverConnection];
}

#pragma mark - Internal Methods

- (void)preloadAdWithConfiguration:(OXMAdConfiguration *)adConfiguration
              withServerConnection:(id<OXMServerConnectionProtocol>)serverConnection {
    
    id<OXMAdLoadManagerProtocol> loadManager = [OXMAdLoadManagerFactory createLoader:serverConnection
                                                                     adConfiguration:adConfiguration];
    loadManager.adLoadManagerDelegate = self;

    [self.loaders addObject:loadManager];

    // TODO: Remove this class
   //  [loadManager load];
}

- (void)dismissLoadManager:(id<OXMAdLoadManagerProtocol>)loadManager {
    if (![self.loaders containsObject:loadManager]) {
        OXMLogError(@"The load manager could be aready dismissed");
        return;
    }
    
    [self.loaders removeObject:loadManager];
    
    if (self.loaders.count == 0 && self.preloadingCompletedBlock) {
        self.preloadingCompletedBlock();
        self.preloadingCompletedBlock = nil;
    }
}

@end
