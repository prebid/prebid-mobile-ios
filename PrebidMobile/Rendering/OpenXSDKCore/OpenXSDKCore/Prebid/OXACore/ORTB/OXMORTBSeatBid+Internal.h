//
//  OXMORTBSeatBid+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#ifndef OXMORTBSeatBid_Internal_h
#define OXMORTBSeatBid_Internal_h

#import "OXMORTBSeatBid.h"
#import "OXMORTBAbstractResponse+Protected.h"

@interface OXMORTBSeatBid<__covariant ExtType, __covariant BidExtType> ()

- (nullable instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary extParser:(ExtType _Nullable (^ _Nonnull)(OXMJsonDictionary * _Nonnull))extParser bidExtParser:(BidExtType _Nullable (^ _Nonnull)(OXMJsonDictionary * _Nonnull))bidExtParser;

@end

#endif /* OXMORTBSeatBid_Internal_h */
