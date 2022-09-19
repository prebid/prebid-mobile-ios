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

#import "PBMORTBAbstractResponse.h"
#import "PBMORTBAbstractResponse+Protected.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@implementation PBMORTBAbstractResponse

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary extParser:(id (^)(PBMJsonDictionary *))extParser {
    if (!(self = [super init])) {
        return nil;
    }
    PBMJsonDictionary * const rawExt = jsonDictionary[@"ext"];
    if (rawExt && extParser) {
        _ext = extParser(rawExt);
    }
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    [self populateJsonDictionary:ret];
    return ret;
}

- (void)populateJsonDictionary:(nonnull PBMMutableJsonDictionary *)jsonDictionary {
    PBMJsonDictionary * const extDic = self.extAsJsonDictionary;
    if (extDic) {
        jsonDictionary[@"ext"] = extDic;
    }
}

- (PBMJsonDictionary *)extAsJsonDictionary {
    if (!self.ext) {
        return nil;
    }
    if ([self.ext isKindOfClass:[PBMORTBAbstract class]]) {
        return [self.ext toJsonDictionary];
    }
    if ([self.ext isKindOfClass:[NSDictionary class]]) {
        return self.ext;
    }
    PBMLogError(@"Could not convert `%@`  (instance of %@) to PBMJsonDictionary -- please override `extAsJsonDictionary` in child class (%@).", [self.ext description], NSStringFromClass([self.ext class]), NSStringFromClass([self class]));
    return nil;
}

@end
