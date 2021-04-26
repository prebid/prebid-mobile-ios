//
//  PBMORTBBidResponse+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#ifndef PBMORTBBidResponse_Protected_h
#define PBMORTBBidResponse_Protected_h

#import "PBMORTBBidResponse.h"
#import "PBMORTBAbstractResponse+Protected.h"

@interface PBMORTBBidResponse<ExtType, SeatBidExtType, BidExtType> ()

- (nullable instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary extParser:(ExtType  _Nullable (^ _Nonnull)(PBMJsonDictionary * _Nonnull))extParser seatBidExtParser:(SeatBidExtType  _Nullable (^ _Nonnull)(PBMJsonDictionary * _Nonnull))seatBidExtParser bidExtParser:(BidExtType  _Nullable (^ _Nonnull)(PBMJsonDictionary * _Nonnull))bidExtParser;

@end

#endif /* PBMORTBBidResponse_Protected_h */
