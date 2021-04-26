//
//  PBMTransactionsCacheManager.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMAdConfiguration.h"
#import "PBMTransactionsCacheManager.h"
#import "PBMAdLoadManagerFactory.h"
#import "PBMAdLoadManagerProtocol.h"
#import "PBMTransaction.h"
#import "PBMTransactionsCache.h"
#import "PBMFunctions+Private.h"
#import "PBMLog.h"

#pragma mark - Private Category

@interface PBMTransactionsCacheManager ()

@property (nonatomic, strong) PBMVoidBlock preloadingCompletedBlock;

@property (nonatomic, assign) PBMTransactionsCache* transactionsCache;
@property (nonatomic, strong) NSMutableArray<id<PBMAdLoadManagerProtocol>> *loaders;

@end

#pragma mark - Implementation

@implementation PBMTransactionsCacheManager

- (instancetype)initWithTransactionsCache:(PBMTransactionsCache *)transactionsCache {
    self = [super init];
    if (self) {
        self.transactionsCache = transactionsCache;
        self.loaders = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - PBMAdLoadManagerDelegate

- (void)loadManager:(id<PBMAdLoadManagerProtocol>)loadManager didLoadTransaction:(PBMTransaction *)transaction {
    [self.transactionsCache addTransaction:transaction];
    
    [self dismissLoadManager:loadManager];
}

- (void)loadManager:(id<PBMAdLoadManagerProtocol>)loadManager failedToLoadTransaction:(PBMTransaction *) transaction error:(NSError *) error {
    PBMLogError(@"Failed to preload video ad with error: %@", [error localizedDescription]);
    
    [self dismissLoadManager:loadManager];
}

#pragma mark - Public Methods

- (void)preloadAdsWithConfigurations:(NSArray<PBMAdConfiguration *> *)configurations
          serverConnection:(id<PBMServerConnectionProtocol>)serverConnection
                completion:(PBMVoidBlock)completion {
    self.preloadingCompletedBlock = completion;
    [configurations enumerateObjectsUsingBlock:^(PBMAdConfiguration *config, NSUInteger idx, BOOL *stop) {
        [self preloadAdWithConfiguration:config withServerConnection:serverConnection];
    }];
}

- (void)preloadAdWithConfiguration:(PBMAdConfiguration *)adConfiguration
                  serverConnection:(id<PBMServerConnectionProtocol>)serverConnection
                        completion:(PBMVoidBlock)completion {
    self.preloadingCompletedBlock = completion;

    [self preloadAdWithConfiguration:adConfiguration withServerConnection:serverConnection];
}

#pragma mark - Internal Methods

- (void)preloadAdWithConfiguration:(PBMAdConfiguration *)adConfiguration
              withServerConnection:(id<PBMServerConnectionProtocol>)serverConnection {
    
    id<PBMAdLoadManagerProtocol> loadManager = [PBMAdLoadManagerFactory createLoader:serverConnection
                                                                     adConfiguration:adConfiguration];
    loadManager.adLoadManagerDelegate = self;

    [self.loaders addObject:loadManager];

    // TODO: Remove this class
   //  [loadManager load];
}

- (void)dismissLoadManager:(id<PBMAdLoadManagerProtocol>)loadManager {
    if (![self.loaders containsObject:loadManager]) {
        PBMLogError(@"The load manager could be aready dismissed");
        return;
    }
    
    [self.loaders removeObject:loadManager];
    
    if (self.loaders.count == 0 && self.preloadingCompletedBlock) {
        self.preloadingCompletedBlock();
        self.preloadingCompletedBlock = nil;
    }
}

@end
