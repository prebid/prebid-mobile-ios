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

#import "NSMutableDictionary+PBMExtensions.h"

static inline BOOL isEmptyVal(id testVal) {
    return !testVal || [testVal isKindOfClass:[NSNull class]];
}

@implementation NSMutableDictionary (Clear)

- (void)pbmRemoveEmptyVals {
    NSArray* keys = self.allKeys;
    for (id key in keys) {
        if (isEmptyVal(self[key])) {
            [self removeObjectForKey:key];
        }
    }
}

- (nonnull NSMutableDictionary *)pbmCopyWithoutEmptyVals {
    
    NSMutableDictionary * const ret = [NSMutableDictionary new];
    
    NSArray * const keys = self.allKeys;
    for (id key in keys) {
        
        const id value = self[key];
        
        if (isEmptyVal(value)) {
            continue;
        }
        
        ret[key] = value;
    }

    return ret;
}

@end
