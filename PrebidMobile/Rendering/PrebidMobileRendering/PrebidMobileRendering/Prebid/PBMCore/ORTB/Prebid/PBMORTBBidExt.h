//
//  PBMORTBBidExt.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract.h"

@class PBMORTBBidExtPrebid;
@class PBMORTBBidExtSkadn;

NS_ASSUME_NONNULL_BEGIN

@interface PBMORTBBidExt : PBMORTBAbstract

@property (nonatomic, strong, nullable) PBMORTBBidExtPrebid *prebid;
@property (nonatomic, copy, nullable) NSDictionary *bidder;

@property (nonatomic, strong, nullable) PBMORTBBidExtSkadn *skadn;

@end

NS_ASSUME_NONNULL_END
