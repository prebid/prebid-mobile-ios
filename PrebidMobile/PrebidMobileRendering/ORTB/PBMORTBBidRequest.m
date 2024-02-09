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
    
    ret[@"id"] = self.requestID;
    ret[@"imp"] = impressions;
    
    ret[@"app"] = [[self.app toJsonDictionary] nullIfEmpty];
    ret[@"device"] = [[self.device toJsonDictionary] nullIfEmpty];
    ret[@"user"] = [[self.user toJsonDictionary] nullIfEmpty];
    ret[@"test"] = self.test;
    ret[@"tmax"] = self.tmax;
    ret[@"regs"] = [[self.regs toJsonDictionary] nullIfEmpty];
    ret[@"source"] = [[self.source toJsonDictionary] nullIfEmpty];
    
    PBMMutableJsonDictionary * const ext = [PBMMutableJsonDictionary new];
    ext[@"prebid"] = [[self.extPrebid toJsonDictionary] nullIfEmpty];
    ret[@"ext"] = [[ext pbmCopyWithoutEmptyVals] nullIfEmpty];
    
    //remove "protected" fields from ortbObject then do a merge but merge ret into the ortbObject (addEntriesFromDictionary)
    NSMutableDictionary *o = [self.arbitraryJsonConfig mutableCopy];
    if (o[@"regs"]) {
        o[@"regs"] = nil;
    }
    if (o[@"device"]) {
        o[@"device"] = nil;
    }
    if (o[@"geo"]) {
        o[@"geo"] = nil;
    }
    //merge with config from API/JSON
    ret = [self mergeDictionaries: ret joiningArgument2: o joiningArgument3: false];
    
    NSMutableDictionary *o2 = [self.ortbObject mutableCopy];
    
    if (o2[@"regs"]) {
        o2[@"regs"] = nil;
    }
    if (o2[@"device"]) {
        o2[@"device"] = nil;
    }
    if (o2[@"geo"]) {
        o[@"geo"] = nil;
    }
    //merge with ortbConfig from SDK
    ret = [self mergeDictionaries: ret joiningArgument2: o2 joiningArgument3: true];
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (nonnull PBMMutableJsonDictionary *)mergeDictionaries:(NSMutableDictionary*)dictionary1 joiningArgument2:(NSMutableDictionary*)dictionary2
                                       joiningArgument3:(Boolean)firstHasPriority{
    PBMMutableJsonDictionary *ret = dictionary1;

    for (id key in dictionary2)
        if ([ret objectForKey: key]){
            if ([[ret objectForKey: key] isKindOfClass: [NSDictionary class]]) {
                //if is dictionary, need to call this method recursively for ret object for key and dictionary2 for key
                [ret setObject:[self mergeDictionaries:[ret objectForKey: key] joiningArgument2: [dictionary2 objectForKey: key] joiningArgument3:firstHasPriority] forKey: key];
            } else {
                if (!firstHasPriority) {
                    [ret setObject:[dictionary2 objectForKey: key] forKey:key];
                }
            }
            //not sure what to do if array of objects
        } else {
            [ret setObject:[dictionary2 objectForKey:key] forKey: key];
        }
        
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
    
    _arbitraryJsonConfig = jsonDictionary;
    
    return self;
}

@end
