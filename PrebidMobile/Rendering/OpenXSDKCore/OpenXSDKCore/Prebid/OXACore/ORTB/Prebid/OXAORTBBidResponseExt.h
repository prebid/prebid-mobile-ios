//
//  OXAORTBBidResponseExt.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAORTBBidResponseExt : OXMORTBAbstract

/// [ (bidder: String) -> (millis: Integer) ]
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSNumber *> *responsetimemillis;

/// [Integer]
@property (nonatomic, strong, nullable) NSNumber *tmaxrequest;

@end

NS_ASSUME_NONNULL_END
