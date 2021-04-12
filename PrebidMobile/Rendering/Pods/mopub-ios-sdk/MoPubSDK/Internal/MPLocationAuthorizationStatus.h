//
//  MPLocationAuthorizationStatus.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Location authorization status that provides slightly more granularity than what
 @c CLAuthorizationStatus can provide alone.
 */
typedef NS_ENUM(NSInteger, MPLocationAuthorizationStatus) {
    /**
     The user has not chosen whether the app can use location services.
     This maps directly to @c kCLAuthorizationStatusNotDetermined
     */
    kMPLocationAuthorizationStatusNotDetermined,

    /**
     The app is not authorized to use location services. The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
     This maps directly to @c kCLAuthorizationStatusRestricted
     */
    kMPLocationAuthorizationStatusRestricted,

    /**
     The user denied the use of location services for the app.
     This is an aggregation of @c kCLAuthorizationStatusDenied and @c CLLocationManager.locationServicesEnabled is set to @c YES
     */
    kMPLocationAuthorizationStatusUserDenied,

    /**
     The system denied the use of location services for the app.
     This is an aggregation of @c kCLAuthorizationStatusDenied and @c CLLocationManager.locationServicesEnabled is set to @c NO
     */
    kMPLocationAuthorizationStatusSettingsDenied,

    /**
     The publisher has denied the use of location services for the app by setting @c MoPub.locationUpdatesEnabled to @c NO.
     The system and user denied statuses take precedence over this value.
     */
    kMPLocationAuthorizationStatusPublisherDenied,

    /**
     The user authorized the app to start location services at any time.
     This maps directly to @c kCLAuthorizationStatusAuthorizedAlways
     */
    kMPLocationAuthorizationStatusAuthorizedAlways,

    /**
     The user authorized the app to start location services while it is in use.
     This maps directly to @c kCLAuthorizationStatusAuthorizedWhenInUse
     */
    kMPLocationAuthorizationStatusAuthorizedWhenInUse,
};

/**
 Converts a @c MPLocationAuthorizationStatus into its equivalent string.
 @param status Status to stringify.
 @return The string representation of the status or @c nil
 */
NSString * _Nullable NSStringFromMPLocationAuthorizationStatus(MPLocationAuthorizationStatus status);

NS_ASSUME_NONNULL_END
