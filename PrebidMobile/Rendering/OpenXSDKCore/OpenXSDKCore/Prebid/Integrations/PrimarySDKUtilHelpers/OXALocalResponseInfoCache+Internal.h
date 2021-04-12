//
//  OXALocalResponseInfoCache+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import <OpenXApolloSDK/OXALocalResponseInfoCache.h>

#import <OpenXApolloSDK/OXADemandResponseInfo.h>
#import "OXAScheduledTimerFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXALocalResponseInfoCache ()

- (NSString *)storeResponseInfo:(OXADemandResponseInfo *)responseInfo;
- (nullable OXADemandResponseInfo *)getStoredResponseInfo:(NSString *)localCacheID;

- (instancetype)initWithScheduledTimerFactory:(OXAScheduledTimerFactory)scheduledTimerFactory
                           expirationInterval:(NSTimeInterval)expirationInterval NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
