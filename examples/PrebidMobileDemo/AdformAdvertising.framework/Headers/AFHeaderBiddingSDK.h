//
//  AFHeaderBiddingSDK.h
//  AdformHeaderBidding
//
//  Created by Vladas Drejeris on 17/02/16.
//  Copyright © 2016 adform. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFHeaderBiddingSDK : NSObject

/**
 Use this property to allow or deny the sdk to use current user location.
 
 By default use of location is disabled.
 Enabling the use of current user location will allow sdk to server ads more accurately.
 
 @warning You need to define NSLocationWhenInUseUsageDescription key in your applications info.plist file, if you don't have one.
 Set it's text to "Your location is used to show relevant ads nearby." or its translation.
 
 @param allow Boolean value indicating if use of current user location should be allowed or denied.
 */
+ (void)setAllowUseOfLocation:(BOOL )allow;

/**
 You can use this to check if the use of current user location is allowed.
 */
+ (BOOL)isUseOfLocationAllowed;

@end
