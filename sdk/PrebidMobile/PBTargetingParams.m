/*   Copyright 2017 Prebid.org, Inc.
 
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

#import "PBTargetingParams.h"

@interface PBTargetingParams ()

@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, NSArray *> *__nullable customKeywords;

@end

@implementation PBTargetingParams

- (instancetype)init {
    if (self = [super init]) {
        _locationPrecision = (NSInteger)-1;
    }
    return self;
}

static PBTargetingParams *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)resetSharedInstance {
    onceToken = 0;
    sharedInstance = nil;
}

- (void)setCustomTargeting:(nonnull NSString *)key
                 withValue:(nonnull NSString *)value {
    if (_customKeywords == nil) {
        _customKeywords = [[NSMutableDictionary alloc] init];
    }

    NSArray *valueArray = [NSArray arrayWithObject:value];
    _customKeywords[key] = valueArray;
}

- (void)setCustomTargeting:(nonnull NSString *)key
                withValues:(nonnull NSArray *)values {
    if (_customKeywords == nil) {
        _customKeywords = [[NSMutableDictionary alloc] init];
    }

    // remove duplicate values from the array
    NSArray *valueArray = [[NSSet setWithArray:values] allObjects];
    _customKeywords[key] = valueArray;
}

- (nullable NSDictionary *)customKeywords {
    return _customKeywords;
}

- (void)removeCustomKeywords {
    if (_customKeywords != nil) {
        [_customKeywords removeAllObjects];
        _customKeywords = nil;
    }
}

- (void)removeCustomKeywordWithKey:(NSString *)key {
    if (_customKeywords != nil) {
        if (_customKeywords[key] != nil) {
            [_customKeywords removeObjectForKey:key];
        }
        if ([_customKeywords count] == 0) {
            _customKeywords = nil;
        }
    }
}

- (void)setLocation:(CLLocation *)location {
    _location = location;
}

- (void)setLocationPrecision:(NSInteger)locationPrecision {
    _locationPrecision = locationPrecision;
}

- (void)setItunesID:(NSString *)itunesID {
    _itunesID = itunesID;
}

@end
