//
//  OXMORTBBidResponse+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#ifndef OXMORTBBidResponse_Protected_h
#define OXMORTBBidResponse_Protected_h

#import "OXMORTBBidResponse.h"
#import "OXMORTBAbstractResponse+Protected.h"

@interface OXMORTBBidResponse<ExtType, SeatBidExtType, BidExtType> ()

- (nullable instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary extParser:(ExtType  _Nullable (^ _Nonnull)(OXMJsonDictionary * _Nonnull))extParser seatBidExtParser:(SeatBidExtType  _Nullable (^ _Nonnull)(OXMJsonDictionary * _Nonnull))seatBidExtParser bidExtParser:(BidExtType  _Nullable (^ _Nonnull)(OXMJsonDictionary * _Nonnull))bidExtParser;

@end

#endif /* OXMORTBBidResponse_Protected_h */
