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

#import "PBMORTBBidRequestExtPrebid.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@implementation PBMORTBBidRequestExtPrebid : PBMORTBAbstract

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
   
    self.targeting = [PBMMutableJsonDictionary new];
    
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    if (!self.storedRequestID) {
        return ret;
    }
    
    if (self.cache) {
        ret[@"cache"] = self.cache;
    }
    
    PBMMutableJsonDictionary * const storedRequest = [PBMMutableJsonDictionary new];
    ret[@"storedrequest"] = storedRequest;
    storedRequest[@"id"] = self.storedRequestID;
    
    if (self.sdkRenderers != nil && self.sdkRenderers.count > 0) {
        NSDictionary * sdk = @{ @"renderers" : self.sdkRenderers };
        ret[@"sdk"] = sdk;
    }
    
    ret[@"targeting"] = self.targeting;
    
    if (self.dataBidders != nil && self.dataBidders.count > 0) {
        ret[@"data"] = @{
            @"bidders": self.dataBidders,
        };
    };
    
    if (self.storedAuctionResponse) {
        ret[@"storedauctionresponse"] = @{@"id":self.storedAuctionResponse};
    }
    
    if (self.storedBidResponses) {
        ret[@"storedbidresponse"] = self.storedBidResponses;
    }
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _storedRequestID = jsonDictionary[@"storedrequest"][@"id"];
    _dataBidders = jsonDictionary[@"data"][@"bidders"];
    _storedAuctionResponse = jsonDictionary[@"storedauctionresponse"][@"id"];
    _storedBidResponses = jsonDictionary[@"storedbidresponse"];
    return self;
}

@end
