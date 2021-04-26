//
//  PBMTransactionsCacheManager.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMAdLoadManagerDelegate.h"
#import "PBMVoidBlock.h"

@class PBMAdConfiguration;
@class PBMTransactionsCache;

@protocol PBMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface PBMTransactionsCacheManager : NSObject <PBMAdLoadManagerDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTransactionsCache:(PBMTransactionsCache *)transactionsCache NS_DESIGNATED_INITIALIZER;

- (void)preloadAdsWithConfigurations:(NSArray<PBMAdConfiguration *> *)configurations
          serverConnection:(id<PBMServerConnectionProtocol>)serverConnection
                completion:(PBMVoidBlock)completion;

- (void)preloadAdWithConfiguration:(PBMAdConfiguration *)adConfiguration
                  serverConnection:(id<PBMServerConnectionProtocol>)serverConnection
                        completion:(PBMVoidBlock)completion;

@end
NS_ASSUME_NONNULL_END
