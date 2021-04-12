//
//  MPIdentityProvider.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPIdentityProvider : NSObject

/**
 Returns @c YES if Limit Ad Tracking is OFF (including if
 @c trackingAuthorizationStatus reports as
 @c ATTrackingManagerAuthorizationStatusAuthorized in iOS 14)

 Returns @c NO if Limit Ad Tracking is ON
 */
@property (class, nonatomic, assign, readonly) BOOL advertisingTrackingEnabled;

/**
 Return IDFA from @c ASIdentiferManager if it's allowed by @c advertisingTrackingEnabled and @c canCollectPersonalInfo.
 Otherwise the value will be @c nil.
 @Note The all zero IDFA @c 00000000-0000-0000-0000-000000000000 will be translated to @c nil.
 */
@property (class, nonatomic, copy, readonly, nullable) NSString *ifa;

/**
 Return IDFV from @c UIDevice.
 */
@property (class, nonatomic, copy, readonly) NSString *ifv;

/**
 Return the MoPub ID. This ID does not rotate as of version 5.14.0 and is not considered PII.
 */
@property (class, nonatomic, copy, readonly) NSString *mopubId;

/**
 Returns the present @c trackingAuthorizationStatus of the application.

 Only available on iOS 14.
 */
@property (class, nonatomic, assign, readonly) ATTrackingManagerAuthorizationStatus trackingAuthorizationStatus API_AVAILABLE(ios(14.0));

/**
 Returns a string description describing the tracking authorization status.

 For iOS 13 and before, this will convert the present @c advertisingTrackingEnabled status
 to a comparable tracking authorization status description.
 */
@property (class, nonatomic, copy, readonly) NSString *trackingAuthorizationStatusDescription;

@end

NS_ASSUME_NONNULL_END
