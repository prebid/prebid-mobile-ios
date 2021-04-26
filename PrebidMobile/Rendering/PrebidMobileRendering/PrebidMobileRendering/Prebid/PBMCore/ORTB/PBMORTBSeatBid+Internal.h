//
//  PBMORTBSeatBid+Internal.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#ifndef PBMORTBSeatBid_Internal_h
#define PBMORTBSeatBid_Internal_h

#import "PBMORTBSeatBid.h"
#import "PBMORTBAbstractResponse+Protected.h"

@interface PBMORTBSeatBid<__covariant ExtType, __covariant BidExtType> ()

- (nullable instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary extParser:(ExtType _Nullable (^ _Nonnull)(PBMJsonDictionary * _Nonnull))extParser bidExtParser:(BidExtType _Nullable (^ _Nonnull)(PBMJsonDictionary * _Nonnull))bidExtParser;

@end

#endif /* PBMORTBSeatBid_Internal_h */
