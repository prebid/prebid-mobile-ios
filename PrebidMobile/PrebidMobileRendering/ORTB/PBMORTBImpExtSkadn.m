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

#import "PBMORTBImpExtSkadn.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMFunctions.h"

@implementation PBMORTBImpExtSkadn

- (instancetype )init {
    if (self = [super init]) {
        _skadnetids = @[];
    }
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [PBMMutableJsonDictionary new];
    
    if (self.sourceapp && self.skadnetids.count > 0) {
        ret[@"versions"] = PBMFunctions.supportedSKAdNetworkVersions;
        ret[@"sourceapp"] = self.sourceapp;
        ret[@"skadnetids"] = self.skadnetids;
        ret[@"skoverlay"] = self.skoverlay;
    }
    
    [ret pbmRemoveEmptyVals];
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (self = [self init]) {
        _sourceapp = jsonDictionary[@"sourceapp"];
        _skadnetids = jsonDictionary[@"skadnetids"];
        _skoverlay = jsonDictionary[@"skoverlay"];
    }

    return self;
}
@end
