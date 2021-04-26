//
//  PBMORTBAbstractResponse+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#ifndef PBMORTBAbstractResponse_Protected_h
#define PBMORTBAbstractResponse_Protected_h

#import "PBMORTBAbstractResponse.h"
#import "PBMORTBAbstract+Protected.h"

@interface PBMORTBAbstractResponse<ExtType> ()

- (nullable instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary extParser:(ExtType _Nullable (^ _Nonnull)(PBMJsonDictionary * _Nonnull))extParser;

- (void)populateJsonDictionary:(nonnull PBMMutableJsonDictionary *)jsonDictionary;

@property (nonatomic, readonly, nullable) PBMJsonDictionary *extAsJsonDictionary;

@end

#endif /* PBMORTBAbstractResponse_Protected_h */
