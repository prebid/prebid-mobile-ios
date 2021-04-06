//
//  OXATargeting.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXAGender.h"
#import "OXANetworkType.h"

typedef NS_ENUM(NSInteger, OXALocationSource) {
    OXALocationSourceGPS                = 1,
    OXALocationSourceIPAddress          = 2,
    OXALocationSourceUserRegistration   = 3,
};

NS_ASSUME_NONNULL_BEGIN

@interface OXATargeting : NSObject

#pragma mark - User Information

/**
 Indicates the end-user's age, in years.
 */
@property (atomic, assign) NSInteger userAge;

/**
 Integer flag indicating if this request is subject to the COPPA regulations
 established by the USA FTC, where 0 = no, 1 = yes
 */
@property (atomic, copy, nullable) NSNumber *coppa;

/**
 Indicates the end-user's gender.
 */
@property (atomic, assign) OXAGender userGender;
/**
 String representation of the users gender,
 where “M” = male, “F” = female, “O” = known to be other (i.e., omitted is unknown)
 */
@property (atomic, copy, readonly, nullable) OXAGenderDescription userGenderDescription;

/**
 Indicates the customer-provided user ID, if different from the Device ID.
 */
@property (atomic, copy, nullable) NSString *userID;

/**
 Buyer-specific ID for the user as mapped by the exchange for the buyer.
 */
@property (atomic, copy, nullable) NSString *buyerUID;

/**
 Comma separated list of keywords, interests, or intent.
 */
@property (atomic, copy, nullable) NSString *keywords;

/**
 Optional feature to pass bidder data that was set in the
 exchange’s cookie. The string must be in base85 cookie safe
 characters and be in any format. Proper JSON encoding must
 be used to include “escaped” quotation marks.
 */
@property (atomic, copy, nullable) NSString *userCustomData;

/**
 Placeholder for User Identity Links.
 The data from this property will be added to usr.ext.eids
 */
@property (atomic, copy, nullable) NSArray<NSDictionary<NSString *, id> *> *eids;

/**
 Placeholder for exchange-specific extensions to OpenRTB.
 */
@property (atomic, strong, nullable) NSMutableDictionary<NSString *, id> *userExt;

#pragma mark - Application Information

/**
 This is the deep-link URL for the app screen that is displaying the ad. This can be an iOS universal link.
 */
@property (atomic, copy, nullable) NSString *contentUrl;

/**
 Indicates the store URL for the mobile application.
 */
@property (atomic, copy, nullable) NSString *appStoreMarketURL;

/**
 App's publisher name.
 */
@property (atomic, copy, nullable) NSString *publisherName;

/**
 ID of publisher app in Apple’s App Store.
 */
@property (atomic, copy, nullable) NSString *sourceapp;

#pragma mark - Location and connection information

#pragma mark - Network

/**
 The IP address of the carrier gateway.
 If this is not present, then OpenX retrieves it from the request header.
 */
@property (atomic, copy, nullable) NSString *IP
    NS_SWIFT_NAME(IP);

/**
 Mobile carrier - Defined by the Mobile Country Code (MCC) and Mobile Network Code (MNC),
 using the format: <MCC>-<MNC>. For example: crr=310-410.
 */
@property (atomic, copy, nullable) NSString *carrier;

/**
 Indicates the end-user's network connection type. For a wireless network, use net=wifi.
 */
@property (atomic, assign) OXANetworkType networkType;

+ (instancetype)shared;
- (instancetype)init NS_UNAVAILABLE;

- (void)resetUserAge;


/**
 This method allows to add new OpenX param by name and set needed value.
 If some ad call parameter doesn't exist in this SDK, you can always set it manually using this method.
 */
- (void)addParam:(NSString *)value withName:(NSString *)name;

/**
 Custom user parameters, a dictionary of name-value parameter pairs, where each param name will be prepended with ‘c.’.
 So for example parameter with name ‘xxx’ will be turned into ‘c.xxx’ when request will be sent.
 */
- (void)setCustomParams:(nullable NSDictionary<NSString *, NSString *> *)params;

/**
 A convenient method to add custom params one by one, here name will also be auto-prepended with ‘c.’.
 Make sure to provide the plain name of the param, like ‘xxx’.
 */
- (void)addCustomParam:(NSString *)value withName:(NSString *)name;

/**
 CLLocationCoordinate2D.
 See CoreLocation framework documentation.
 */
@property (atomic, strong, nullable) NSValue *coordinate;

/**
 Convenience setter for latitude and longitude of a geographic location
 @param latitude - Latitude from -90.0 to +90.0, where negative is south
 @param longitude - Longitude from -180.0 to +180.0, where negative is west
 */
- (void)setLatitude:(double)latitude longitude:(double)longitude;


- (void)addBidderToAccessControlList:(NSString *)bidderName;
- (void)removeBidderFromAccessControlList:(NSString *)bidderName;
- (void)clearAccessControlList;


- (void)addUserData:(NSString *)value forKey:(NSString *)key;
- (void)updateUserData:(NSSet<NSString *> *)value forKey:(NSString *)key;
- (void)removeUserDataForKey:(NSString *)key;
- (void)clearUserData;


- (void)addContextData:(NSString *)value forKey:(NSString *)key;
- (void)updateContextData:(NSSet<NSString *> *)value forKey:(NSString *)key;
- (void)removeContextDataForKey:(NSString *)key;
- (void)clearContextData;

@end

NS_ASSUME_NONNULL_END
