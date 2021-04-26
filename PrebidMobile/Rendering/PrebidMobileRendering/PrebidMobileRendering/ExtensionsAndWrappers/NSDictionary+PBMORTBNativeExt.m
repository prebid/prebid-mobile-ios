//
//  NSDictionary+PBMORTBNativeExt.m
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "NSDictionary+PBMORTBNativeExt.h"
#import "PBMConstants.h"
#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"

@implementation NSDictionary (PBMORTBNativeExt)

- (nullable PBMJsonDictionary *)unserializedCopyWithError:(NSError * _Nullable __autoreleasing * _Nonnull)error {
    *error = nil;
    NSString * const serializedExt = [PBMFunctions toStringJsonDictionary:self error:error];
    if (*error) {
        return nil;
    }
    PBMJsonDictionary * const extClone = [PBMFunctions dictionaryFromJSONString:serializedExt error:error];
    if (*error) {
        return nil;
    }
    return extClone;
}

@end
