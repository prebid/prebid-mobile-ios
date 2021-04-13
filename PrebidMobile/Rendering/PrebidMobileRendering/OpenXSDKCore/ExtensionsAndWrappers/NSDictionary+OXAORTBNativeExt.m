//
//  NSDictionary+OXAORTBNativeExt.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "NSDictionary+OXAORTBNativeExt.h"
#import "OXMConstants.h"
#import "OXMFunctions.h"
#import "OXMFunctions+Private.h"

@implementation NSDictionary (OXAORTBNativeExt)

- (nullable OXMJsonDictionary *)unserializedCopyWithError:(NSError * _Nullable __autoreleasing * _Nonnull)error {
    *error = nil;
    NSString * const serializedExt = [OXMFunctions toStringJsonDictionary:self error:error];
    if (*error) {
        return nil;
    }
    OXMJsonDictionary * const extClone = [OXMFunctions dictionaryFromJSONString:serializedExt error:error];
    if (*error) {
        return nil;
    }
    return extClone;
}

@end
