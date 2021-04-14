//
//  OXAORTBBidExtPrebidCache.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAbstract.h"

@class OXAORTBBidExtPrebidCacheBids;

NS_ASSUME_NONNULL_BEGIN

@interface OXAORTBBidExtPrebidCache : OXMORTBAbstract

@property (nonatomic, copy, nullable) NSString *key;
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, strong, nullable) OXAORTBBidExtPrebidCacheBids *bids;

@end

NS_ASSUME_NONNULL_END
