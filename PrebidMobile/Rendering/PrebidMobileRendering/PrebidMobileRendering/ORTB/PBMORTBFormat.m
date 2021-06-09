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

#import "PBMORTBFormat.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBFormat

- (instancetype)init {
    if(!(self = [super init])) {
        return nil;
    }
    // nop -- all fields are nil
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"w"] = self.w;
    ret[@"h"] = self.h;
    ret[@"wratio"] = self.wratio;
    ret[@"hratio"] = self.hratio;
    ret[@"wmin"] = self.wmin;
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if(!(self = [super init])) {
        return nil;
    }
    _w = jsonDictionary[@"w"];
    _h = jsonDictionary[@"h"];
    _wratio = jsonDictionary[@"wratio"];
    _hratio = jsonDictionary[@"hratio"];
    _wmin = jsonDictionary[@"wmin"];
    
    return self;
}

@end
