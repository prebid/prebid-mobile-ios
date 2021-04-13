//
//  OXAORTBBidExt.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAbstract.h"

@class OXAORTBBidExtPrebid;
@class OXAORTBBidExtSkadn;

NS_ASSUME_NONNULL_BEGIN

@interface OXAORTBBidExt : OXMORTBAbstract

@property (nonatomic, strong, nullable) OXAORTBBidExtPrebid *prebid;
@property (nonatomic, copy, nullable) NSDictionary *bidder;

@property (nonatomic, strong, nullable) OXAORTBBidExtSkadn *skadn;

@end

NS_ASSUME_NONNULL_END
