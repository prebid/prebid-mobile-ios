//
//  OXMORTBAbstract+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#ifndef OXMORTBAbstract_Protected_h
#define OXMORTBAbstract_Protected_h

#import "OXMORTBAbstract.h"

#import "NSDictionary+OxmExtensions.h"
#import "NSMutableDictionary+OxmExtensions.h"
#import "OXMConstants.h"
#import "OXMFunctions.h"

@interface OXMORTBAbstract ()

- (nonnull OXMJsonDictionary *)toJsonDictionary;
- (nullable instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary;

@end

#endif /* OXMORTBAbstract_Protected_h */
