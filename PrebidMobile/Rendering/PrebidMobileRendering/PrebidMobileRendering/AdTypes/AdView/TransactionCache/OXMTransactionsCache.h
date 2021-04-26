//
//  PBMTransactionsCache.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMTransaction;
@class PBMAdConfiguration;

NS_ASSUME_NONNULL_BEGIN
@interface PBMTransactionsCache : NSObject

@property (class, readonly, nonnull) PBMTransactionsCache *singleton;

/** Adds a given transaction to the cache. Saves the new list of tags. */
- (void)addTransaction:(PBMTransaction *)transaction;

/**
 Reterns transaction for a given configuration.
 Returns nil if there is no corespondent transaction in the cache.
 Returned transaction is removed from the cache.
*/
- (nullable PBMTransaction *)extractTransactionForConfiguration:(PBMAdConfiguration *)adConfiguration;

/**
 Removes all transactions from the cache.
 Removes all tags from cached list.
*/
- (void)clear;

@end
NS_ASSUME_NONNULL_END
