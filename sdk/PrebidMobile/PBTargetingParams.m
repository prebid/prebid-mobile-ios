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
@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, NSArray *> *__nullable userKeywords;

@end

@implementation PBTargetingParams


- (instancetype)init {
    if (self = [super init]) {
        _locationPrecision = (NSInteger)-1;
        
        _customKeywords = [[NSMutableDictionary alloc] init];
        _userKeywords = [[NSMutableDictionary alloc] init];
        
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
        return;
    }

    NSArray *valueArray = [NSArray arrayWithObject:value];
    _customKeywords[key] = valueArray;
}

- (void)setCustomTargeting:(nonnull NSString *)key
                withValues:(nonnull NSArray *)values {
    if (_customKeywords == nil) {
        return;
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

#pragma mark User Keywords

- (void)setUserKeywords:(nonnull NSString *)key
                 withValue:(NSString * _Nullable)value {
    if (_userKeywords == nil) {
        return;
    }
    
    if(value == nil || value == NULL){
        value = @"";
    }
    
    NSArray *valueArray = [NSArray arrayWithObject:value];
    _userKeywords[key] = valueArray;
}

- (void)setUserKeywords:(nonnull NSString *)key
                withValues:(NSArray * _Nullable)values {
    if (_userKeywords == nil) {
        return;
    }
    
    
    // remove duplicate values from the array
    NSArray *valueArray = [[NSSet setWithArray:values] allObjects];
    _userKeywords[key] = valueArray;
}

- (nullable NSDictionary *)userKeywords {
    return _userKeywords;
}

- (void)removeUserKeywords {
    if (_userKeywords != nil) {
        [_userKeywords removeAllObjects];
        _userKeywords = nil;
    }
}

- (void)removeUserKeywordWithKey:(NSString *)key {
    if (_userKeywords != nil) {
        if (_userKeywords[key] != nil) {
            [_userKeywords removeObjectForKey:key];
        }
        if ([_userKeywords count] == 0) {
            _userKeywords = nil;
        }
    }
}

#pragma end

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
