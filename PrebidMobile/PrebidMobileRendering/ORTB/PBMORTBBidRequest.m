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

#import "PBMORTBBidRequest.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBApp.h"
#import "PBMORTBBidRequestExtPrebid.h"
#import "PBMORTBDevice.h"
#import "PBMORTBImp.h"
#import "PBMORTBRegs.h"
#import "PBMORTBSource.h"
#import "PBMORTBUser.h"

@implementation PBMORTBBidRequest

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    //_requestID = nil;
    _imp = @[[PBMORTBImp new]];
    _app = [PBMORTBApp new];
    _device = [PBMORTBDevice new];
    _user = [PBMORTBUser new];
    _regs = [PBMORTBRegs new];
    _source = [PBMORTBSource new];
    _extPrebid = [PBMORTBBidRequestExtPrebid new];
    
    return self;
}
- (void)setImp:(NSArray<PBMORTBImp *> *)imp {
    _imp = imp ? [NSArray arrayWithArray:imp] : @[];
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    NSMutableArray<PBMJsonDictionary *> *impressions = [NSMutableArray<PBMJsonDictionary *> new];
    for (PBMORTBImp *imp in self.imp) {
        [impressions addObject:[imp toJsonDictionary]];
    }
    //set impressions and ext beforehand so they are not overridden by arbitrary params from API/JSON
    ret[@"imp"] = impressions;
    PBMMutableJsonDictionary * const ext = [PBMMutableJsonDictionary new];
    ext[@"prebid"] = [[self.extPrebid toJsonDictionary] nullIfEmpty];
    ret[@"ext"] = [[ext pbmCopyWithoutEmptyVals] nullIfEmpty];
    
    ret[@"id"] = self.requestID;
    
    ret[@"app"] = [[self.app toJsonDictionary] nullIfEmpty];
    ret[@"device"] = [[self.device toJsonDictionary] nullIfEmpty];
    ret[@"user"] = [[self.user toJsonDictionary] nullIfEmpty];
    ret[@"test"] = self.test;
    ret[@"tmax"] = self.tmax;
    ret[@"regs"] = [[self.regs toJsonDictionary] nullIfEmpty];
    ret[@"source"] = [[self.source toJsonDictionary] nullIfEmpty];
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    
    _requestID = jsonDictionary[@"id"];
    
    NSMutableArray<PBMORTBImp *> *impressions = [NSMutableArray<PBMORTBImp *> new];
    NSMutableArray<PBMJsonDictionary *> *impressionsData = jsonDictionary[@"imp"];
    for (PBMJsonDictionary *impressionData in impressionsData) {
        if (impressionData && [impressionData isKindOfClass:[NSDictionary class]])
            [impressions addObject:[[PBMORTBImp alloc] initWithJsonDictionary:impressionData]];
    }
    
    _imp = impressions;
    
    _app = [[PBMORTBApp alloc] initWithJsonDictionary:jsonDictionary[@"app"]];
    _device = [[PBMORTBDevice alloc] initWithJsonDictionary:jsonDictionary[@"device"]];
    _user = [[PBMORTBUser alloc] initWithJsonDictionary:jsonDictionary[@"user"]];
    _test = jsonDictionary[@"test"];
    _tmax = jsonDictionary[@"tmax"];
    _regs = [[PBMORTBRegs alloc] initWithJsonDictionary:jsonDictionary[@"regs"]];
    _source = [[PBMORTBSource alloc] initWithJsonDictionary:jsonDictionary[@"source"]];
    _extPrebid = [[PBMORTBBidRequestExtPrebid alloc] initWithJsonDictionary:jsonDictionary[@"ext"][@"prebid"] ?: @{}];
    
    return self;
}

@end
