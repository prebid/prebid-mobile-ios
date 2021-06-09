/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */


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
