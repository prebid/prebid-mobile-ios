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

#import "PBMORTBImpExtPrebid.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBImpExtPrebid : PBMORTBAbstract

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    
    _isRewardedInventory = false;
    
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [PBMMutableJsonDictionary new];
    
    if (!self.storedRequestID) {
        return ret;
    }
    
    PBMMutableJsonDictionary * const storedRequest = [PBMMutableJsonDictionary new];
    storedRequest[@"id"] = self.storedRequestID;

    ret[@"storedrequest"] = storedRequest;
    
    if (self.isRewardedInventory) {
        ret[@"is_rewarded_inventory"] = @(1);
    }
    
    if(self.storedAuctionResponse) {
        ret[@"storedauctionresponse"] = @{@"id":self.storedAuctionResponse};
    }
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    
    _storedRequestID = jsonDictionary[@"storedrequest"][@"id"];
    _isRewardedInventory = jsonDictionary[@"is_rewarded_inventory"] != nil;
    
    _storedAuctionResponse = jsonDictionary[@"storedauctionresponse"][@"id"];
    
    return self;
}

@end
