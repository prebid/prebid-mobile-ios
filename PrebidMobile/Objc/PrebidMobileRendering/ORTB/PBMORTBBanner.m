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

#import "PBMORTBBanner.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBFormat.h"

@implementation PBMORTBBanner

- (nonnull instancetype)init {
    if(!(self = [super init])) {
        return nil;
    }
    _format = @[];
    return self;
}

- (void)setFormat:(NSArray<PBMORTBFormat *> *)format {
    _format = format ? [NSArray arrayWithArray:format] : @[];
}

- (void)setApi:(NSArray<NSNumber *> *)api {
    _api = api ? [NSArray arrayWithArray:api] : nil;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"pos"] = self.pos;
    
    if (self.api.count > 0) {
        ret[@"api"] = self.api;
    }
    
    if (self.format.count > 0) {
        NSMutableArray<PBMJsonDictionary *> * const formatsArr = [[NSMutableArray alloc] initWithCapacity:self.format.count];
        for(PBMORTBFormat *nextFormat in self.format) {
            [formatsArr addObject:[nextFormat toJsonDictionary]];
        }
        ret[@"format"] = formatsArr;
    }
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if(!(self = [super init])) {
        return nil;
    }
    _pos = jsonDictionary[@"pos"];
    _api = jsonDictionary[@"api"];
    
    NSArray<PBMJsonDictionary *> * const formatsArr = jsonDictionary[@"format"];
    if (formatsArr) {
        NSMutableArray<PBMORTBFormat *> * const newFormat = [[NSMutableArray alloc] initWithCapacity:formatsArr.count];
        for(PBMJsonDictionary *nextFormatDic in jsonDictionary[@"format"]) {
            [newFormat addObject:[[PBMORTBFormat alloc] initWithJsonDictionary:nextFormatDic]];
        }
        _format = newFormat;
    } else {
        _format = @[];
    }
    
    return self;
}

@end
