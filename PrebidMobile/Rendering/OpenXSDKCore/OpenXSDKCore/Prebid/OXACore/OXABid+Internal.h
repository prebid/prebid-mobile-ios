//
//  OXABid+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import "OXABid.h"

@class OXMORTBBid<ExtType>;
@class OXAORTBBidExt;

NS_ASSUME_NONNULL_BEGIN

@interface OXABid()

@property (nonatomic, strong, readonly, nonnull) OXMORTBBid<OXAORTBBidExt *> *bid;

- (nullable instancetype)initWithBid:(OXMORTBBid<OXAORTBBidExt *> *)bid;

@end

NS_ASSUME_NONNULL_END

