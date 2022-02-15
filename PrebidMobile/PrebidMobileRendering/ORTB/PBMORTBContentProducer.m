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


#import "PBMORTBContentProducer.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBContentProducer : PBMORTBAbstract

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"id"] = self.id;
    ret[@"name"] = self.name;
    ret[@"cat"] = self.cat;
    ret[@"domain"] = self.domain;
    
    if (self.ext && self.ext.count) {
        ret[@"ext"] = self.ext;
    }
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    
    _id = jsonDictionary[@"id"];
    _name = jsonDictionary[@"name"];
    _cat = jsonDictionary[@"cat"];
    _domain = jsonDictionary[@"domain"];
    _ext = jsonDictionary[@"ext"];
    
    return self;
}

@end
