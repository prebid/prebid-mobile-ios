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

#import "PBMORTBBidResponseExtPrebid.h"

@implementation PBMORTBBidResponseExtPrebid

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }
    
    NSArray<PBMJsonDictionary *> *const passthroughDics = [PBMFunctions dictionariesForPassthrough:jsonDictionary[@"passthrough"]];
    _passthrough = nil;
    if (passthroughDics) {
        NSMutableArray * const newPassthrough = [[NSMutableArray alloc] initWithCapacity:passthroughDics.count];
        for(PBMJsonDictionary *nextDic in passthroughDics) {
            PBMORTBExtPrebidPassthrough * const nextPassthrough = [[PBMORTBExtPrebidPassthrough alloc] initWithJsonDictionary:nextDic];
            if (nextPassthrough) {
                [newPassthrough addObject:nextPassthrough];
            }
        }
        if (newPassthrough.count > 0) {
            _passthrough = newPassthrough;
        }
    }
    
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    NSMutableArray * const passthroughDicArr = [[NSMutableArray alloc] initWithCapacity:self.passthrough.count];
    for(PBMORTBExtPrebidPassthrough *nextPassthrough in self.passthrough) {
        [passthroughDicArr addObject:[nextPassthrough toJsonDictionary]];
    }
    
    if (passthroughDicArr.count > 0) {
        ret[@"passthrough"] = passthroughDicArr;
    }
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end
