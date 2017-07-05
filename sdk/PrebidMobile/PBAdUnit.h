/*   Copyright 2017 APPNEXUS INC
 
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

#import <UIKit/UIKit.h>

@protocol CGSize;

/**
 * A generic ad unit object that the user creates to configure the ad sizes. These are passed to the
 * prebid server adapter and ads are fetched for each ad unit
 */
@interface PBAdUnit : NSObject

/**
 * uuid is a auto generated id for each of the ad unit created.
 */
@property (nonatomic, readonly) NSString *__nullable uuid;

/**
 * identifier is the developer identity for an ad unit. identifier needs to be unique for each ad unit.
 */
@property (nonatomic, readonly) NSString *__nullable identifier;

/**
 * configId is the prebid server config id for an ad unit. configId needs to be unique for each ad unit.
 */
@property (nonatomic, readonly) NSString *__nullable configId;

/**
 * adSizes is a list of CGSizes (widths & heights) that needs to be fetched for the ad unit.
 */
@property (nonatomic, readonly) NSArray<CGSize> *__nullable adSizes;

/**
 * An enumeration object that holds different types of ad units available to be configured for
 * the ad units can be configured only for banner, interstitial or native ads
 */
typedef NS_ENUM(NSInteger, PBAdUnitType) {
    PBAdUnitTypeBanner,
    PBAdUnitTypeInterstitial,
    PBAdUnitTypeNative
};

@property (nonatomic, readonly) PBAdUnitType adType;

/**
 * initializes the PBAdUnit object with the identifier & the adUnit type
 * @param identifier : identifier is the developer identity for the ad unit
 * @param type : type of adUnit created. Can be banner, interstitial or native
 * @param configId : config id for demand sources from prebid server
 */
- (nonnull instancetype)initWithIdentifier:(nonnull NSString *)identifier andAdType:(PBAdUnitType)type andConfigId:(nonnull NSString *)configId;

/**
 * addSize adds the size object to the adUnit object created
 * @param adSize : width & height of the ad that needs to be fetched
 */
- (void)addSize:(CGSize)adSize;

/**
 * generatesUUID generates a new uuid on the ad unit
 */
- (void)generateUUID;

/**
 * shouldExpireAllBids returns a boolean if the adUnit should expire all bids given a time
 * @param time : time is the current time
 */
- (BOOL)shouldExpireAllBids:(NSTimeInterval)time;

/**
 * setTimeIntervalToExpireAllBids sets the expiryTime for all bids on this ad unit
 * @param expiryTime : expiryTime is the time that the bids will all expire
 */
- (void)setTimeIntervalToExpireAllBids:(NSTimeInterval)expiryTime;

/**
 * isEqualToAdUnit tests for equality to another adUnit.
 * two ad units are considered equal if their identifiers are equal
 */
- (BOOL)isEqualToAdUnit:(nonnull PBAdUnit *)otherAdUnit;

@end
