//
//  PBMBid+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import "PBMBid.h"

@class PBMORTBBid<ExtType>;
@class PBMORTBBidExt;

NS_ASSUME_NONNULL_BEGIN

@interface PBMBid()

@property (nonatomic, strong, readonly, nonnull) PBMORTBBid<PBMORTBBidExt *> *bid;

- (nullable instancetype)initWithBid:(PBMORTBBid<PBMORTBBidExt *> *)bid;

@end

NS_ASSUME_NONNULL_END

