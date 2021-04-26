//
//  PBMGAMUtils+Internal.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMGAMUtils.h"
#import <PrebidMobileRendering/PBMLocalResponseInfoCache.h>
#import "PBMLocalResponseInfoCache+Internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMGAMUtils ()

- (instancetype)initWithLocalCache:(PBMLocalResponseInfoCache *)localCache;

@end

NS_ASSUME_NONNULL_END
