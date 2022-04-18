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

#import "PBMORTBAbstract+Protected.h"
#import "PBMORTBExtPrebidPassthrough.h"
#import "PBMORTBAdConfiguration.h"

@implementation PBMORTBExtPrebidPassthrough

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    if (!(self = [super init])) {
        return nil;
    }

    _type = jsonDictionary[@"type"];
    
    PBMJsonDictionary * const adConfigDic = jsonDictionary[@"adconfiguration"];
    
    if (adConfigDic) {
        _adConfiguration = [[PBMORTBAdConfiguration alloc] initWithJsonDictionary:adConfigDic];
    }
    
    return self;
}

- (PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary * const ret = [[PBMMutableJsonDictionary alloc] init];
    
    ret[@"type"] = self.type;
    
    ret[@"adConfiguration"] = [self.adConfiguration toJsonDictionary];
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

@end
