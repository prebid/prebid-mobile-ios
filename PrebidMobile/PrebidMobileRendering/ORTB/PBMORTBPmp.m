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

#import "PBMORTBPmp.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBDeal.h"

@implementation PBMORTBPmp

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _deals = @[];
    
    return self;
}

- (void)setDeals:(NSArray<PBMORTBDeal *> *)deals {
    _deals = deals ? [NSArray arrayWithArray:deals] : @[];
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"private_auction"] = self.private_auction;
    
    NSMutableArray<PBMJsonDictionary *> *deals = [NSMutableArray<PBMJsonDictionary *> new];
    for (PBMORTBDeal *deal in self.deals) {
        [deals addObject:[deal toJsonDictionary]];
    }
    if (deals.count > 0) {
        ret[@"deals"] = deals;
    }
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _private_auction = jsonDictionary[@"private_auction"];
    
    NSMutableArray<PBMORTBDeal *> *deals = [NSMutableArray<PBMORTBDeal *> new];

    NSArray *dealsData = jsonDictionary[@"deals"];
    for (PBMJsonDictionary *dealData in dealsData) {
        if (dealData && [dealData isKindOfClass:[NSDictionary class]]) {
            [deals addObject:[[PBMORTBDeal alloc] initWithJsonDictionary:dealData]];
        }
    }
    
    _deals = deals;
    
    return self;
}

@end
