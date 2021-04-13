//
//  OXMORTBAbstractResponse+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#ifndef OXMORTBAbstractResponse_Protected_h
#define OXMORTBAbstractResponse_Protected_h

#import "OXMORTBAbstractResponse.h"
#import "OXMORTBAbstract+Protected.h"

@interface OXMORTBAbstractResponse<ExtType> ()

- (nullable instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary extParser:(ExtType _Nullable (^ _Nonnull)(OXMJsonDictionary * _Nonnull))extParser;

- (void)populateJsonDictionary:(nonnull OXMMutableJsonDictionary *)jsonDictionary;

@property (nonatomic, readonly, nullable) OXMJsonDictionary *extAsJsonDictionary;

@end

#endif /* OXMORTBAbstractResponse_Protected_h */
