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

#import "PBMORTBBidResponseExt.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBBidResponseExt

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    _responsetimemillis = jsonDictionary[@"responsetimemillis"];
    _tmaxrequest = jsonDictionary[@"tmaxrequest"];
    
    PBMJsonDictionary * extPrebid = jsonDictionary[@"prebid"];
    if (extPrebid) {
        _extPrebid = [[PBMORTBBidResponseExtPrebid alloc] initWithJsonDictionary:extPrebid];
    }
    
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"responsetimemillis"] = self.responsetimemillis;
    ret[@"tmaxrequest"] = self.tmaxrequest;
    ret[@"prebid"] = [self.extPrebid toJsonDictionary];
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end
