//
//  OXMORTBPmp.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAbstract.h"

@class OXMORTBDeal;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.11: Pmp

//This object is the private marketplace container for direct deals between buyers and sellers that may
//pertain to this impression. The actual deals are represented as a collection of Deal objects. Refer to
//Section 7.3 for more details.
@interface OXMORTBPmp : OXMORTBAbstract
    
//Int. Indicator of auction eligibility to seats named in the Direct Deals object, where 0 = all bids are accepted, 1 = bids are restricted to the deals specified and the terms thereof
@property (nonatomic, strong, nullable) NSNumber *private_auction;

//Array of Deal (Section 3.2.18) objects that convey the specific deals applicable to this impression
@property (nonatomic, copy) NSArray<OXMORTBDeal *> *deals;

//Placeholder for exchange-specific extensions to OpenRTB.
//Note: ext is not supported.

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
