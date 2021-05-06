//
//  PBMLocalResponseInfoCache+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import <PrebidMobileRendering/PBMLocalResponseInfoCache.h>

#import <PrebidMobileRendering/PBMDemandResponseInfo.h>
#import <PrebidMobileRendering/PBMScheduledTimerFactory.h>
//#import "PBMScheduledTimerFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMLocalResponseInfoCache ()

- (NSString *)storeResponseInfo:(PBMDemandResponseInfo *)responseInfo;
- (nullable PBMDemandResponseInfo *)getStoredResponseInfo:(NSString *)localCacheID;

- (instancetype)initWithScheduledTimerFactory:(PBMScheduledTimerFactory)scheduledTimerFactory
                           expirationInterval:(NSTimeInterval)expirationInterval NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
