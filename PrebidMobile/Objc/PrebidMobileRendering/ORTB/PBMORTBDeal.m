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

#import "PBMORTBDeal.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBDeal

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _bidfloor = @(0.0);
    _bidfloorcur = @"USD";
    _wseat = @[];
    _wadomain = @[];
    
    return self;
}
- (void)setWseat:(NSArray<NSString *> *)wseat {
    _wseat = wseat ? [NSArray arrayWithArray:wseat] : @[];
}
- (void)setWadomain:(NSArray<NSString *> *)wadomain {
    _wadomain = wadomain ? [NSArray arrayWithArray:wadomain] : @[];
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"id"] = self.id;
    ret[@"bidfloor"] = self.bidfloor;
    ret[@"bidfloorcur"] = self.bidfloorcur;
    ret[@"at"] = self.at;
    ret[@"wseat"] = self.wseat;
    ret[@"wadomain"] = self.wadomain;
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _id = jsonDictionary[@"id"];
    _bidfloor = jsonDictionary[@"bidfloor"];
    _bidfloorcur = jsonDictionary[@"bidfloorcur"];
    _at = jsonDictionary[@"at"];
    _wseat = jsonDictionary[@"wseat"];
    _wadomain = jsonDictionary[@"wadomain"];
    
    return self;
}

@end
