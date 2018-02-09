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

#import <CoreLocation/CoreLocation.h>

/**
 * Gender selection enumerator to be passed in by the user
 */
typedef NS_ENUM(NSUInteger, PBTargetingParamsGender) {
    PBTargetingParamsGenderUnknown = 0,
    PBTargetingParamsGenderFemale,
    PBTargetingParamsGenderMale
};

@interface PBTargetingParams : NSObject

+ (nonnull instancetype)sharedInstance;

#ifdef DEBUG
+ (void)resetSharedInstance;
#endif

/**
 * This property gets the age value set by the application developer
 */
@property (nonatomic, assign, readwrite) NSInteger age;

/**
 * This property gets the gender enum passed set by the developer
 */
@property (nonatomic, assign, readwrite) PBTargetingParamsGender gender;

/**
 * The application location for targeting
 */
@property (nonatomic, readwrite) CLLocation *__nullable location;

/**
 * The application location precision for targeting
 */
@property (nonatomic, readwrite) NSInteger locationPrecision;

/**
 * The itunes app id for targeting
 */
@property (nonatomic, readwrite) NSString *__nullable itunesID;

/**
 * This property stores the set of custom keywords that price check provides for targeting
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSArray *> *__nullable customKeywords;

/**
 * This method obtains the custom keyword & value for targeting framed by the developer
 */
- (void)setCustomTargeting:(nonnull NSString *)key
                 withValue:(nonnull NSString *)value;
/**
 * This method obtains the custom keyword & value set for targeting framed by the developer
 */
- (void)setCustomTargeting:(nonnull NSString *)key
                withValues:(nonnull NSArray *)values;

/**
 * This method allows the developer to remove all the custom keywords set for targeting
 */
- (void)removeCustomKeywords;

/**
 * This method allows the developer to remove specific custom keyword & value set from targeting
 */
- (void)removeCustomKeywordWithKey:(nonnull NSString *)key;

@end
