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

#import "PBMORTBApp.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBPublisher.h"
#import "PBMORTBAppExt.h"
#import "PBMORTBAppContent.h"

@implementation PBMORTBApp

- (nonnull instancetype )init {
    if (!(self = [super init])) {
        return nil;
    }
    _cat = @[];
    _sectioncat = @[];
    _pagecat = @[];
    _publisher = [[PBMORTBPublisher alloc] init];
    _ext = [[PBMORTBAppExt alloc] init];
    _content = [[PBMORTBAppContent alloc] init];
    
    return self;
}

- (void)setCat:(NSArray<NSString *> *)cat {
    _cat = cat ? [NSArray arrayWithArray:cat] : @[];
}

- (void)setSectioncat:(NSArray<NSString *> *)sectioncat {
    _sectioncat = sectioncat ? [NSArray arrayWithArray:sectioncat] : @[];
}

- (void)setPagecat:(NSArray<NSString *> *)pagecat {
    _pagecat = pagecat ? [NSArray arrayWithArray:pagecat] : @[];
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"id"] = self.id;
    ret[@"name"] = self.name;
    ret[@"bundle"] = self.bundle;
    ret[@"domain"] = self.domain;
    ret[@"storeurl"] = self.storeurl;
    ret[@"ver"] = self.ver;
    ret[@"privacypolicy"] = self.privacypolicy;
    ret[@"paid"] = self.paid;
    ret[@"keywords"] = self.keywords;
    ret[@"publisher"] = [[self.publisher toJsonDictionary] nullIfEmpty];
    ret[@"content"] = [[self.content toJsonDictionary] nullIfEmpty];
    ret[@"ext"] = [[self.ext toJsonDictionary] nullIfEmpty];
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _id = jsonDictionary[@"id"];
    _name = jsonDictionary[@"name"];
    _bundle = jsonDictionary[@"bundle"];
    _domain = jsonDictionary[@"domain"];
    _storeurl = jsonDictionary[@"storeurl"];
    _cat = jsonDictionary[@"cat"];
    _sectioncat = jsonDictionary[@"sectioncat"];
    _pagecat = jsonDictionary[@"pagecat"];
    _ver = jsonDictionary[@"ver"] ;
    _privacypolicy = jsonDictionary[@"privacypolicy"];
    _paid = jsonDictionary[@"paid"];
    _publisher = [[PBMORTBPublisher alloc] initWithJsonDictionary:jsonDictionary[@"publisher"]];
    _keywords = jsonDictionary[@"keywords"];
    _ext = [[PBMORTBAppExt alloc] initWithJsonDictionary:jsonDictionary[@"ext"]];
    _content = [[PBMORTBAppContent alloc] initWithJsonDictionary:jsonDictionary[@"content"]];
    
    return self;
}

@end
