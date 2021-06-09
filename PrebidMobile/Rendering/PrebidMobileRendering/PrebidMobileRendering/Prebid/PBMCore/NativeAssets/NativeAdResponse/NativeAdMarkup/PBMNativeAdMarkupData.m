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

#import "PBMNativeAdMarkupData.h"

#import "PBMConstants.h"
#import "PBMLog.h"

@implementation PBMNativeAdMarkupData

- (instancetype)initWithValue:(NSString *)value {
    if (!(self = [super init])) {
        return nil;
    }
    _value = [value copy];
    return self;
}

- (nullable instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary
                                          error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    if (!(self = [super init])) {
        return nil;
    }
    _dataType = jsonDictionary[@"type"];
    _length = jsonDictionary[@"len"];
    _value = [jsonDictionary[@"value"] copy];
    _ext = jsonDictionary[@"ext"];
    
    if (!_value) {
        PBMLogWarn(@"Required property 'value' is absent in jsonDict for nativeAsset.data");
    }
    if (error) {
        *error = nil;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    PBMNativeAdMarkupData *other = object;
    BOOL (^ const objComparator)(id (^)(id)) = ^BOOL(id (^extractor)(id)) {
        id lhs = extractor(self);
        id rhs = extractor(other);
        return (lhs == nil) ? (rhs == nil) : [lhs isEqual:rhs];
    };
    return ((self == other)
            || (objComparator(^(PBMNativeAdMarkupData *src) { return src.dataType; })
                && objComparator(^(PBMNativeAdMarkupData *src) { return src.length; })
                && objComparator(^(PBMNativeAdMarkupData *src) { return src.value; })
                && objComparator(^(PBMNativeAdMarkupData *src) { return src.ext; })
                )
            );
}

@end
