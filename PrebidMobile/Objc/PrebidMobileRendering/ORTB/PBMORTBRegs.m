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

#import "PBMORTBRegs.h"
#import "PBMORTBAbstract+Protected.h"

@interface PBMORTBRegs ()
    @property (nonatomic, copy) NSNumber *_coppa;
@end


@implementation PBMORTBRegs

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }

    _ext = [PBMMutableJsonDictionary new];

    return self;
}

- (NSNumber *)coppa {
    return self._coppa;
}

- (void)setCoppa:(NSNumber *)newValue {
    
    if (newValue) {
        if ([newValue isEqualToNumber:@(1)] || [newValue isEqualToNumber:@(0)]) {
            self._coppa = newValue;
            return;
        }
    }
    
    self._coppa = nil;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"coppa"] = self._coppa;
    ret[@"gpp"] = self.gpp;
    ret[@"gpp_sid"] = self.gppSID;
    
    ret[@"ext"] = [self.ext nullIfEmpty];

    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    __coppa = jsonDictionary[@"coppa"];
    
    return self;
}

@end
