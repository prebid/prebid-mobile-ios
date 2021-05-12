//
//  MPFullscreenAdAdapterDelegate.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPMediationSettingsProtocol.h"
#import "MPReward.h"

NS_ASSUME_NONNULL_BEGIN

@class MPFullscreenAdAdapter;

/**
 Delegate of @c FullscreenAdAdapter.
 */
@protocol MPFullscreenAdAdapterDelegate <NSObject>

/**
 Call this method to get the customer ID associated with this adapter.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this method call with
 the correct instance of your adapter.

 @return The user's customer ID.
 */
- (NSString * _Nullable)customerIdForAdapter:(MPFullscreenAdAdapter *)adapter;

/**
 Call this method to retrieve a mediation settings object (if one is provided by the application)
 for this instance of your ad.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this method call with
 the correct instance of your adapter.
 @param aClass The specific mediation settings class your adapter uses
 to configure itself for its ad network.
 */
- (id<MPMediationSettingsProtocol> _Nullable)fullscreenAdAdapter:(MPFullscreenAdAdapter *)adapter instanceMediationSettingsForClass:(Class)aClass;

/**
 Call this method immediately after an ad loads succesfully.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the
 correct instance of your adapter.

 @warning **Important**: Your adapter subclass **must** call this method when it successfully loads an ad.
 Failure to do so will disrupt the mediation waterfall and cause future ad requests to stall.
 */
- (void)fullscreenAdAdapterDidLoadAd:(MPFullscreenAdAdapter *)adapter;

/**
 Call this method immediately after an ad fails to load.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the
 correct instance of your adapter.
 @param error The error describing why the ad load failed.

 @warning **Important**: Your adapter subclass **must** call this method
 when it fails to load an ad. Failure to do so will disrupt the mediation waterfall
  and cause future ad requests to stall.
 */
- (void)fullscreenAdAdapter:(MPFullscreenAdAdapter * _Nullable)adapter didFailToLoadAdWithError:(NSError * _Nullable)error;

/**
 Call this method when the application has attempted to show an ad and it cannot be shown.

 A common usage of this delegate method is when the application tries to play an ad and an ad
 is not available for play.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the
 correct instance of your adapter.
 @param error The error describing why the video couldn't play.
 */
- (void)fullscreenAdAdapter:(MPFullscreenAdAdapter *)adapter didFailToShowAdWithError:(NSError *)error;

/**
 Call this method when the user should be rewarded.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the
 correct instance of your adapter.
 @param reward The reward object that contains the currency type as well as the amount that should
 be rewarded to the user. If the concept of currency type doesn't exist for the ad network, set the
 reward's currency type to @c MPRewardCurrencyTypeUnspecified.
 */
- (void)fullscreenAdAdapter:(MPFullscreenAdAdapter *)adapter willRewardUser:(MPReward *)reward;

/**
 Call this method if a previously loaded fullscreen ad should no longer be eligible for presentation.

 Some third-party networks will mark fullscreen ads as expired (indicating they should not be
 presented) *after* they have loaded.  You may use this method to inform the MoPub SDK that a
 previously loaded fullscreen ad has expired and that a new fullscreen ad should be obtained.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.
 */
- (void)fullscreenAdAdapterDidExpire:(MPFullscreenAdAdapter *)adapter;

/**
 Call this method when an ad is about to appear.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.

 @warning **Important**: Your adapter subclass **must** call this method when it is about to present
 the fullscreen ad. Failure to do so will disrupt the mediation waterfall and cause future ad requests
 to stall.
 */
- (void)fullscreenAdAdapterAdWillAppear:(MPFullscreenAdAdapter *)adapter;

/**
 Call this method when an ad has finished appearing.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.

 @warning **Important**: Your adapter subclass **must** call this method when it is finished presenting
 the fullscreen ad. Failure to do so will disrupt the mediation waterfall and cause future ad requests
 to stall.

 **Note**: if it is not possible to know when the fullscreen ad *finished* appearing, you should call
 this immediately after calling @c fullscreenAdAdapterAdWillAppear:.
 */
- (void)fullscreenAdAdapterAdDidAppear:(MPFullscreenAdAdapter *)adapter;

/**
 Call this method when an ad is about to disappear.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.

 @warning **Important**: Your adapter subclass **must** call this method when it is about to dismiss the
 fullscreen ad. Failure to do so will disrupt the mediation waterfall and cause future ad requests to stall.
 */
- (void)fullscreenAdAdapterAdWillDisappear:(MPFullscreenAdAdapter *)adapter;

/**
 Call this method when an ad has finished disappearing.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.

 @warning **Important**: Your adapter subclass **must** call this method when it is finished with dismissing
 the fullscreen ad. Failure to do so will disrupt the mediation waterfall and cause future ad requests to stall.

 **Note**: if it is not possible to know when the fullscreen ad *finished* dismissing, you should call
 this immediately after calling @c fullscreenAdAdapterAdWillDisappear:.
 */
- (void)fullscreenAdAdapterAdDidDisappear:(MPFullscreenAdAdapter *)adapter;

/**
 Call this method when the user taps on the fullscreen ad.

 This method is optional. When automatic click and impression tracking is enabled (the default)
 this method will track a click (the click is guaranteed to only be tracked once per ad).

 **Note**: some third-party networks provide a "will leave application" callback instead of/in
 addition to a "user did click" callback. You should call this method in response to either of
 those callbacks (since leaving the application is generally an indicator of a user tap).

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.
 */
- (void)fullscreenAdAdapterDidReceiveTap:(MPFullscreenAdAdapter *)adapter;

/**
 Call this method when the fullscreen ad will cause the user to leave the application.

 For example, the user may have tapped on a link to visit the App Store or Safari.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.
 */
- (void)fullscreenAdAdapterWillLeaveApplication:(MPFullscreenAdAdapter *)adapter;

/**
 Call this method when the fullscreen ad will dismiss.

 For example, the user has closed the fullscreen ad.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.
 */
- (void)fullscreenAdAdapterAdWillDismiss:(MPFullscreenAdAdapter *)adapter;

/**
 Call this method when the fullscreen ad did dismiss.

 For example, the user has closed the fullscreen ad.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.
 */
- (void)fullscreenAdAdapterAdDidDismiss:(MPFullscreenAdAdapter *)adapter;

/** @name Impression and Click Tracking */

/**
 Call this to track an impression.

 The MoPub SDK ensures that only one impression is tracked per adapter. Calling this method after an
 impression has been tracked (either by another call to this method, or automatically if
 @c enableAutomaticClickAndImpressionTracking is set to @c YES) will do nothing.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.
 */
- (void)fullscreenAdAdapterDidTrackImpression:(MPFullscreenAdAdapter *)adapter;

/**
 Call this to track a click.

 The MoPub SDK ensures that only one click is tracked per adapter. Calling this method after a click has
 been tracked (either by another call to this method, or automatically if
 @c enableAutomaticClickAndImpressionTracking is set to @c YES) will do nothing.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.
 */
- (void)fullscreenAdAdapterDidTrackClick:(MPFullscreenAdAdapter *)adapter;

@end

NS_ASSUME_NONNULL_END
