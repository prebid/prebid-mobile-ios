//
//  PBMORTBBidExtPrebidCache.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract.h"

@class PBMORTBBidExtPrebidCacheBids;

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBBidExtPrebidCache : PBMORTBAbstract

@property (nonatomic, copy, nullable) NSString *key;
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, strong, nullable) PBMORTBBidExtPrebidCacheBids *bids;

@end

NS_ASSUME_NONNULL_END
