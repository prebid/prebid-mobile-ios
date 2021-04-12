//
//  OXAORTBBidExtPrebid.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAbstract.h"

@class OXAORTBBidExtPrebidCache;

NS_ASSUME_NONNULL_BEGIN

@interface OXAORTBBidExtPrebid : OXMORTBAbstract

@property (nonatomic, strong, nullable) OXAORTBBidExtPrebidCache *cache;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *targeting;
@property (nonatomic, copy, nullable) NSString *type;

@end

NS_ASSUME_NONNULL_END
