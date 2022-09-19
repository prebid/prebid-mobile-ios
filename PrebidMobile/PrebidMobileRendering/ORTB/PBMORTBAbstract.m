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

#import "PBMORTBAbstract+Protected.h"
#import "PBMFunctions+Private.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@implementation PBMORTBAbstract

// MARK: - Public

- (nullable NSString *)toJsonStringWithError:(NSError* _Nullable __autoreleasing * _Nullable)error {
    PBMJsonDictionary *jsonDictionary = [self toJsonDictionary];
    return [PBMFunctions toStringJsonDictionary:jsonDictionary error:error];
}

+ (instancetype)fromJsonString:(nonnull NSString *)jsonString error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    PBMJsonDictionary* dictionary = [PBMFunctions dictionaryFromJSONString:jsonString
                                                                     error:error];
    
    return [[self alloc] initWithJsonDictionary:dictionary];
}

// MARK: - <NSCopying>

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    NSError *error;
    return [[self class] fromJsonString:[self toJsonStringWithError:&error] error:&error];
}

// MARK: - Protected

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMLogError(@"You must override %@ in a subclass", NSStringFromSelector(_cmd));
    return [PBMJsonDictionary new];
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    PBMLogError(@"You should not initialize abstract class directly");
    return [PBMORTBAbstract new];
}

@end
