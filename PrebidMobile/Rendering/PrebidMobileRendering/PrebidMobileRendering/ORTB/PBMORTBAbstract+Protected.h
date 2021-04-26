//
//  PBMORTBAbstract+Protected.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBAbstract.h"

#import "NSDictionary+PBMExtensions.h"
#import "NSMutableDictionary+PBMExtensions.h"
#import "PBMConstants.h"
#import "PBMFunctions.h"

@interface PBMORTBAbstract ()

- (nonnull PBMJsonDictionary *)toJsonDictionary;
- (nullable instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary;

@end

