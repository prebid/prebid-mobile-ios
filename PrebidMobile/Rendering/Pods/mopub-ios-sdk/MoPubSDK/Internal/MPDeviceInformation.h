//
//  MPDeviceInformation.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "MPATSSetting.h"
#import "MPLocationAuthorizationStatus.h"
#import "MPNetworkStatus.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Read-only information pertaining to the current state of the device.
 */
@interface MPDeviceInformation : NSObject

#pragma mark - Application Metadata

/**
 The current App Transport Security settings of the device.
 */
@property (class, nonatomic, readonly) MPATSSetting appTransportSecuritySettings;

/**
 The version of the application, as listed in its Info.plist.
 */
@property (class, nonatomic, readonly) NSString *applicationVersion;

#pragma mark - Connectivity

/**
 The current radio technology used by the device to connect to the internet.
 */
@property (class, nonatomic, readonly) MPNetworkStatus currentRadioAccessTechnology;

/**
 The currently cached carrier name.
 */
@property (class, nullable, nonatomic, copy, readonly) NSString * carrierName;

/**
 The currently cached carrier ISO country code.
 */
@property (class, nullable, nonatomic, copy, readonly) NSString * isoCountryCode;

/**
 The currently cached carrier mobile country code.
 */
@property (class, nullable, nonatomic, copy, readonly) NSString * mobileCountryCode;

/**
 The currently cached carrier mobile network code.
 */
@property (class, nullable, nonatomic, copy, readonly) NSString * mobileNetworkCode;

#pragma mark - Location

/**
 Flag indicating that location can be queried from @c CLLocationManager. The default value is @c YES.
 */
@property (class, nonatomic, assign) BOOL enableLocation;

/**
 Current location authorization status.
 */
@property (class, nonatomic, readonly) MPLocationAuthorizationStatus locationAuthorizationStatus;

/**
 The last known valid location. This will be @c nil if there is no authorization to acquire the location, or if @c enableLocation has been set to @c NO.
 */
@property (class, nullable, nonatomic, readonly) CLLocation * lastLocation;

@end

NS_ASSUME_NONNULL_END
