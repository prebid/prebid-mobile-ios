//
//  PBMORTBBidExtPrebid.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract.h"

@class PBMORTBBidExtPrebidCache;

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBBidExtPrebid : PBMORTBAbstract

@property (nonatomic, strong, nullable) PBMORTBBidExtPrebidCache *cache;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *targeting;
@property (nonatomic, copy, nullable) NSString *type;

@end

NS_ASSUME_NONNULL_END
