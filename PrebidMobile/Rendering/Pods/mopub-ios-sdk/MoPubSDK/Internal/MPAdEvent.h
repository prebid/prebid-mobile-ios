//
//  MPAdEvent.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

/**
 Events with public parameter(s) are not defined here, such as fail to load and impression tracking.
 */
typedef NS_ENUM(NSUInteger, MPInlineAdEvent) {
    /**
     The ad will cause the user to leave the application.
     For example, the user may have tapped on a link to visit the App Store or Safari.
     Note: some third-party networks provide a "will leave application" event instead of / in
     addition to a "user did click" event since leaving the application is generally an indicator
     of a user tap.
     */
    MPInlineAdEventWillLeaveApplication,

    /**
     This event notifies that the user started interacting iwth the ad (i.e., the clickthrough modal will be presented)
     */
    MPInlineAdEventUserActionWillBegin,

    /**
     This event notifies that the user stopped interacting with the ad (i.e., the clickthrough modal was dismissed)
     */
    MPInlineAdEventUserActionDidEnd,

    /**
     This event notifies that the inline ad will expand.
     */
    MPInlineAdEventWillExpand,

    /**
     This event notifies that expanded inline ad will collapse.
     */
    MPInlineAdEventDidCollapse
};

/**
 Events with public parameter(s) are not defined here, such as fail to load, fail to play, and impression tracking.
 */
typedef NS_ENUM(NSUInteger, MPFullscreenAdEvent) {
    /**
     An ad loads succesfully.
     */
    MPFullscreenAdEventDidLoad,

    /**
     A previously loaded ad should no longer be eligible for presentation.
     */
    MPFullscreenAdEventDidExpire,

    /**
     The user taps on the ad.
     Note: some third-party networks provide a "will leave application" event instead of / in
     addition to a "user did click" event since leaving the application is generally an indicator
     of a user tap.
     */
    MPFullscreenAdEventDidReceiveTap,

    /**
     The ad will cause the user to leave the application.
     For example, the user may have tapped on a link to visit the App Store or Safari.
     Note: some third-party networks provide a "will leave application" event instead of / in
     addition to a "user did click" event since leaving the application is generally an indicator
     of a user tap.
     */
    MPFullscreenAdEventWillLeaveApplication,

    /**
     An ad is about to appear.
     */
    MPFullscreenAdEventWillAppear,

    /**
     An ad has finished appearing.
     */
    MPFullscreenAdEventDidAppear,

    /**
     An ad is about to disappear.
     */
    MPFullscreenAdEventWillDisappear,

    /**
     The ad did disappear.
     */
    MPFullscreenAdEventDidDisappear,

    /**
     The fullscreen ad will be dismissed by the user.
     */
    MPFullscreenAdEventWillDismiss,

    /**
     The fullscreen ad has finished dismissing.
     */
    MPFullscreenAdEventDidDismiss
};
