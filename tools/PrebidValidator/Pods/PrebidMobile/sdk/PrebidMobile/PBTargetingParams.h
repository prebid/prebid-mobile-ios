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
 * This property stores the set of custom keywords that prebid provides for targeting
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSArray *> *__nullable customKeywords DEPRECATED_ATTRIBUTE;

/**
 * This method obtains the custom keyword & value for targeting framed by the developer
 */
- (void)setCustomTargeting:(nonnull NSString *)key
                 withValue:(nonnull NSString *)value __deprecated;
/**
 * This method obtains the custom keyword & value set for targeting framed by the developer
 */
- (void)setCustomTargeting:(nonnull NSString *)key
                withValues:(nonnull NSArray *)values __deprecated;

/**
 * This method allows the developer to remove all the custom keywords set for targeting
 */
- (void)removeCustomKeywords __deprecated;

/**
 * This method allows the developer to remove specific custom keyword & value set from targeting
 */
- (void)removeCustomKeywordWithKey:(nonnull NSString *)key __deprecated;

/**
 * This property stores the set of user keywords that openRTB provides for targeting
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSArray *> *__nullable userKeywords;

/**
 * This method obtains the user keyword & value for targeting framed by the developer
 */
- (void)setUserKeywords:(nonnull NSString *)key
              withValue:(NSString *_Nullable)value;
/**
 * This method obtains the user keyword & value set for targeting framed by the developer
 */
- (void)setUserKeywords:(nonnull NSString *)key
             withValues:(NSArray *_Nullable)values;

/**
 * This method allows the developer to remove all the user keywords set for targeting
 */
- (void)removeUserKeywords;

/**
 * This method allows the developer to remove specific user keyword & value set from targeting
 */
- (void)removeUserKeywordWithKey:(nonnull NSString *)key;

@end
