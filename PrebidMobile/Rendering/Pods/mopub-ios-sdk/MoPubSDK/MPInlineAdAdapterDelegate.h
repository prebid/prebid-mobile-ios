//
//  MPInlineAdAdapterDelegate.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class MPInlineAdAdapter;

/**
 Instances of your custom subclass of @c MPInlineAdAdapter will have an
 @c MPInlineAdAdapterDelegate delegate. You use this delegate to communicate events ad events
 back to the MoPub SDK.

 When mediating a third party ad network it is important to call as many of these methods
 as accurately as possible.  Not all ad networks support all these events, and some support
 different events.  It is your responsibility to find an appropriate mapping between the ad
 network's events and the callbacks defined on @c MPInlineAdAdapterDelegate.
 */

@protocol MPInlineAdAdapterDelegate <NSObject>

/**
 The view controller instance to use when presenting modals.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.

 @return the view controller that was specified when implementing the @c MPAdViewDelegate protocol.
 */
- (UIViewController *)inlineAdAdapterViewControllerForPresentingModalView:(MPInlineAdAdapter *)adapter;

/** @name Banner Ad Event Callbacks - Fetching Ads */

/**
 Call this method immediately after an ad loads succesfully.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.

 @param adView The @c UIView representing the banner ad.  This view will be inserted into the parent
 @c MPAdView and presented to the user by the MoPub SDK.

 @warning **Important**: Your adapter subclass **must** call this method when it successfully loads an ad.
 Failure to do so will disrupt the mediation waterfall and cause future ad requests to stall.
 */
- (void)inlineAdAdapter:(MPInlineAdAdapter *)adapter didLoadAdWithAdView:(UIView *)adView;

/**
 Call this method immediately after an ad fails to load.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.

 @param error the error describing the failure.

 @warning **Important**: Your adapter subclass **must** call this method when it fails to load an ad.
 Failure to do so will disrupt the mediation waterfall and cause future ad requests to stall.
 */
- (void)inlineAdAdapter:(MPInlineAdAdapter *)adapter didFailToLoadAdWithError:(NSError *)error;

/** @name Banner Ad Event Callbacks - User Interaction */

/**
 Call this method when the user taps on the banner ad.

 This method is optional.  When automatic click and impression tracking is enabled (the default)
 this method will track a click (the click is guaranteed to only be tracked once per ad).

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.

 @warning **Important**: If you call @c inlineAdAdapterWillBeginUserAction:, you _**must**_ also call
 @c inlineAdAdapterDidEndUserAction: at a later point.
 */
- (void)inlineAdAdapterWillBeginUserAction:(MPInlineAdAdapter *)adapter;

/**
 Call this method when the user finishes interacting with the banner ad.

 For example, the user may have dismissed any modal content. This method is optional.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.

 @warning **Important**: If you call @c inlineAdAdapterWillBeginUserAction:, you _**must**_ also call
 @c inlineAdAdapterDidEndUserAction: at a later point.
 */
- (void)inlineAdAdapterDidEndUserAction:(MPInlineAdAdapter *)adapter;

/**
 Call this method when the banner ad will cause the user to leave the application.

 For example, the user may have tapped on a link to visit the App Store or Safari.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.
 */
- (void)inlineAdAdapterWillLeaveApplication:(MPInlineAdAdapter *)adapter;

/**
 Call this method when the banner ad is expanding or resizing from its default size.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.
 */
- (void)inlineAdAdapterWillExpand:(MPInlineAdAdapter *)adapter;

/**
 Call this method when the banner ad is collapsing back to its default size.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.
 */
- (void)inlineAdAdapterDidCollapse:(MPInlineAdAdapter *)adapter;

/** @name Impression and Click Tracking */

/**
 Call this method when an impression was tracked.

 The MoPub SDK ensures that only one impression is tracked per adapter. Calling this method after an
 impression has been tracked (either by another call to this method, or automatically if
 @c enableAutomaticClickAndImpressionTracking is set to @c YES) will do nothing.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.
 */
- (void)inlineAdAdapterDidTrackImpression:(MPInlineAdAdapter *)adapter;

/**
 Call this method when a click was tracked.

 The MoPub SDK ensures that only one click is tracked per adapter. Calling this method after a click has
 been tracked (either by another call to this method, or automatically if
 @c enableAutomaticClickAndImpressionTracking is set to @c YES) will do nothing.

 @param adapter You should pass @c self to allow the MoPub SDK to associate this event with the correct
 instance of your adapter.
 */
- (void)inlineAdAdapterDidTrackClick:(MPInlineAdAdapter *)adapter;

@end
