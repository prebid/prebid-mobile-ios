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


#import "PBMORTBContentData.h"
#import "PBMORTBAbstract+Protected.h"

#import "PBMORTBContentSegment.h"

@implementation PBMORTBContentData : PBMORTBAbstract

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
    
    if(self.segment) {
        NSMutableArray<PBMJsonDictionary *> *segmentsArray = [NSMutableArray<PBMJsonDictionary *> new];
        for (PBMORTBContentSegment *segmentObject in self.segment) {
            [segmentsArray addObject:[segmentObject toJsonDictionary]];
        }
        
        ret[@"segment"] = segmentsArray;
    }
    
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
    
    NSMutableArray<PBMORTBContentSegment *> *segmentsArray = [NSMutableArray<PBMORTBContentSegment *> new];
    NSMutableArray<PBMJsonDictionary *> *segmentsData = jsonDictionary[@"segment"];
    if (segmentsData.count > 0) {
        for (PBMJsonDictionary *segmentData in segmentsData) {
            if (segmentData && [segmentData isKindOfClass:[NSDictionary class]])
                [segmentsArray addObject:[[PBMORTBContentSegment alloc] initWithJsonDictionary:segmentData]];
        }
        _segment = segmentsArray;
    }
    
    _ext = jsonDictionary[@"ext"];
    
    return self;
}

@end
