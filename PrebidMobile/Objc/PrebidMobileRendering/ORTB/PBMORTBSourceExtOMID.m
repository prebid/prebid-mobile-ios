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

#import "PBMORTBSourceExtOMID.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBSourceExtOMID

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    ret[@"omidpn"] = self.omidpn;
    ret[@"omidpv"] = self.omidpv;
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _omidpn = jsonDictionary[@"omidpn"];
    _omidpv = jsonDictionary[@"omidpv"];
    return self;
}

@end
