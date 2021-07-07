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

#import "PBMORTBPublisher.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBPublisher

- (nonnull instancetype )init {
    if (!(self = [super init])) {
        return nil;
    }
    _cat = @[];
    
    return self;
}

- (void)setCat:(NSArray<NSString *> *)cat {
    _cat = cat ? [NSArray arrayWithArray:cat] : @[];
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"id"] = self.publisherID;
    ret[@"name"] = self.name;
    ret[@"domain"] = self.domain;
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _publisherID = jsonDictionary[@"id"];
    _name = jsonDictionary[@"name"];
    _domain = jsonDictionary[@"domain"];
    _cat = jsonDictionary[@"cat"];
    
    return self;
}

@end
