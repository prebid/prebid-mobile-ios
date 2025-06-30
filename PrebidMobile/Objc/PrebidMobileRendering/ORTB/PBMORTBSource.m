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

#import "PBMORTBSource.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBSourceExtOMID.h"

@implementation PBMORTBSource

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _extOMID = [[PBMORTBSourceExtOMID alloc] init];
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    ret[@"fd"] = self.fd;
    ret[@"tid"] = self.tid;
    ret[@"pchain"] = self.pchain;
    
    PBMJsonDictionary * const extOmidDic = [self.extOMID toJsonDictionary];
    if (extOmidDic.count) {
        ret[@"ext"] = extOmidDic;
    }
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _fd = jsonDictionary[@"fd"];
    _tid = jsonDictionary[@"tid"];
    _pchain = jsonDictionary[@"pchain"];
    
    _extOMID = [[PBMORTBSourceExtOMID alloc] initWithJsonDictionary:jsonDictionary[@"ext"]];
    
    return self;
}

@end
