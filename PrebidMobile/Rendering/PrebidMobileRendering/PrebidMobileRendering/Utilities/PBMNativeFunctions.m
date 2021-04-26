//
//  PBMNativeFunctions.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//


#import "PBMFunctions+Private.h"
#import "PBMLog.h"

#import "PBMNativeFunctions.h"

static NSString *macrosFormat = @"%%%%PATTERN:%@%%%%";
static NSString *macrosTargetingMap = @"%%PATTERN:TARGETINGMAP%%";

static NSString *absentKeysRegexp =@"(\"%%PATTERN:.*%%\")|(%%PATTERN:.*%%)";

@implementation PBMNativeFunctions

+ (nullable NSString *)populateNativeAdTemplate:(NSString *)nativeTemplate
                         withTargeting:(NSDictionary<NSString *, NSString *> *)targeting
                                 error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    
    NSMutableString *resultTemplate = [nativeTemplate mutableCopy];
    
    NSError *err = nil;
    NSString * targetingMapString = [PBMFunctions toStringJsonDictionary:targeting error:&err];
    if (err) {
        PBMLogInfo(@"[ERROR]: %@", err);
        if (error) {
            *error = err;
        }
        return nil;
    }
    
    [resultTemplate replaceOccurrencesOfString:macrosTargetingMap
                                    withString:targetingMapString
                                       options:0
                                         range:NSMakeRange(0, resultTemplate.length)];
    
    for(NSString *targetingKey in targeting) {
        NSString *macros = [NSString stringWithFormat:macrosFormat, targetingKey];
        [resultTemplate replaceOccurrencesOfString:macros
                                        withString:targeting[targetingKey]
                                           options:0
                                             range:NSMakeRange(0, resultTemplate.length)];
    }
    
    [resultTemplate replaceOccurrencesOfString:absentKeysRegexp
                                    withString:@"null"
                                       options:NSRegularExpressionSearch
                                         range:NSMakeRange(0, resultTemplate.length)];
    return resultTemplate;
}

@end
