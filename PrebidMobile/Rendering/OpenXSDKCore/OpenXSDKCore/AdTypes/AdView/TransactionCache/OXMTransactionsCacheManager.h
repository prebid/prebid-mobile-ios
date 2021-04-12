//
//  OXMTransactionsCacheManager.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMAdLoadManagerDelegate.h"
#import "OXMVoidBlock.h"

@class OXMAdConfiguration;
@class OXMTransactionsCache;

@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN
@interface OXMTransactionsCacheManager : NSObject <OXMAdLoadManagerDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTransactionsCache:(OXMTransactionsCache *)transactionsCache NS_DESIGNATED_INITIALIZER;

- (void)preloadAdsWithConfigurations:(NSArray<OXMAdConfiguration *> *)configurations
          serverConnection:(id<OXMServerConnectionProtocol>)serverConnection
                completion:(OXMVoidBlock)completion;

- (void)preloadAdWithConfiguration:(OXMAdConfiguration *)adConfiguration
                  serverConnection:(id<OXMServerConnectionProtocol>)serverConnection
                        completion:(OXMVoidBlock)completion;

@end
NS_ASSUME_NONNULL_END
