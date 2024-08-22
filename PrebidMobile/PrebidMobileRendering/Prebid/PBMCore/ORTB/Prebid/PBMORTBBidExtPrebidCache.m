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

#import "PBMORTBBidExtPrebidCache.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBBidExtPrebidCacheBids.h"

@implementation PBMORTBBidExtPrebidCache

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    _url = jsonDictionary[@"url"];
    _key = jsonDictionary[@"key"];
    
    
    PBMJsonDictionary * const bidsDic = jsonDictionary[@"bids"];
    if (bidsDic) {
        _bids = [[PBMORTBBidExtPrebidCacheBids alloc] initWithJsonDictionary:bidsDic];
    }
    
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"key"] = self.key;
    ret[@"url"] = self.url;
    
    ret[@"bids"] = [[self.bids toJsonDictionary] nullIfEmpty];
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end
