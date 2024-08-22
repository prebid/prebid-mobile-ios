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

#import <Foundation/Foundation.h>

#import "PBMORTBAbstract+Protected.h"
#import "PBMORTBBidExtSkadn.h"

@implementation PBMORTBBidExtSkadn

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (self = [super init]) {
        _version = jsonDictionary[@"version"];
        _network = jsonDictionary[@"network"];
        _campaign = jsonDictionary[@"campaign"];
        _itunesitem = jsonDictionary[@"itunesitem"];
        _sourceapp = jsonDictionary[@"sourceapp"];
        _sourceidentifier = jsonDictionary[@"sourceidentifier"];
        
        NSMutableArray<PBMORTBSkadnFidelity *> *fidelities = [NSMutableArray<PBMORTBSkadnFidelity *> new];
        NSMutableArray<PBMJsonDictionary *> *fidelitiesData = jsonDictionary[@"fidelities"];
        
        for (PBMJsonDictionary *fidelityData in fidelitiesData) {
            if (fidelityData && [fidelityData isKindOfClass:[NSDictionary class]])
                [fidelities addObject:[[PBMORTBSkadnFidelity alloc] initWithJsonDictionary:fidelityData]];
        }
        
        _fidelities = fidelities;
    }
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"version"] = self.version;
    ret[@"network"] = self.network;
    ret[@"campaign"] = self.campaign;
    ret[@"itunesitem"] = self.itunesitem;
    ret[@"sourceapp"] = self.sourceapp;
    ret[@"sourceidentifier"] = self.sourceidentifier;
    
    NSMutableArray<PBMJsonDictionary *> *jsonFidelities = [NSMutableArray<PBMJsonDictionary *> new];
    for (PBMORTBSkadnFidelity *fidelity in self.fidelities) {
        PBMJsonDictionary *jsonFidelity = [fidelity toJsonDictionary];
        [jsonFidelities addObject:jsonFidelity];
    }
    
    ret[@"fidelities"] = jsonFidelities;
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end
