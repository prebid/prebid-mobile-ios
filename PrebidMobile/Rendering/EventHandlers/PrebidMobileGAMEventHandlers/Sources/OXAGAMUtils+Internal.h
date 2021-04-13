//
//  OXAGAMUtils+Internal.h
//  OpenXApolloGAMEventHandlers
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAGAMUtils.h"
#import <PrebidMobileRendering/OXALocalResponseInfoCache.h>
#import "OXALocalResponseInfoCache+Internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAGAMUtils ()

- (instancetype)initWithLocalCache:(OXALocalResponseInfoCache *)localCache;

@end

NS_ASSUME_NONNULL_END
