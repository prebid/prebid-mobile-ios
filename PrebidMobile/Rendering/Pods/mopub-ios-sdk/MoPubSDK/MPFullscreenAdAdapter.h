//
//  MPFullscreenAdAdapter.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "MPFullscreenAdAdapterDelegate.h"
#import "MPScheduledDeallocationAdAdapter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The MoPub iOS SDK mediates third party Ad Networks using adapters. The adapters are
 responsible for instantiating and manipulating objects in the third party SDK and translating
 and communicating events from those objects back to the MoPub SDK by notifying a delegate.

 @c MPFullscreenAdAdapter is a base class for adapters that support full-screen interstitial ads.
 By implementing subclasses of @c MPFullscreenAdAdapter you can enable the MoPub SDK to
 natively support a wide variety of third-party ad networks.

 At runtime, the MoPub SDK will find and instantiate an @c MPFullscreenAdAdapter subclass as needed and
 invoke its @c requestAdWithAdapterInfo:adMarkup: method.
 */
@protocol MPFullscreenAdAdapter <MPScheduledDeallocationAdAdapter>

/**
 Override to opt out of automatic ad level impression and click tracking.

 By default, the @c MPFullscreenAdAdapterDelegate will automatically record impression and click events
 in response to @c fullscreenAdAdapterAdDidAppear: and @c fullscreenAdAdapterDidReceiveTap:. If automatic
 ad level impression and click tracking is not desired (for some of the 3rd party ad adapters), override
 this behavior by implementing this method to return @c NO.

 @warning **Important**: If you override this, you are responsible for calling the
 fullscreenAdAdapterDidTrackImpression: and @c fullscreenAdAdapterDidTrackClick: methods of
 @c MPFullscreenAdAdapterDelegate. Additionally, you must make sure that
 @c fullscreenAdAdapterDidTrackImpression: and @c fullscreenAdAdapterDidTrackClick: are each called at
 most **once** per ad.
 */
@property (nonatomic, readonly) BOOL enableAutomaticImpressionAndClickTracking;

/**
 Indicates if an adapter is rewarded.

 Ad adapters must override this property and return @c YES to enable the rewarded experience.
 */
@property (nonatomic, readonly) BOOL isRewardExpected;

/**
 Called when the MoPubSDK wants to know if an ad is currently available for the ad network.

 This call is typically invoked when the application wants to check whether an ad unit has an ad
 ready to display.

 @warning overriding and implementing this property is required for rewarded ads.
 */
@property (nonatomic, assign, readonly) BOOL hasAdAvailable;

/**
 An optional dictionary containing extra local data.
 */
@property (nonatomic, copy, nullable) NSDictionary *localExtras;

/**
 Called when the MoPub SDK requires a new ad.

 When the MoPub SDK receives a response indicating it should load an adapter, it will send this
 message to your adapter class. Your implementation of this method should load a fullscreen ad
 from a third-party ad network. It must also notify the @c MPFullscreenAdAdapterDelegate of certain
 lifecycle events.

 @param info A dictionary containing additional custom data associated with a given adapter
 request. This data is configurable on the MoPub website, and may be used to pass dynamic information,
 such as publisher IDs.
 @param adMarkup An optional ad markup to use.
 */
- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString * _Nullable)adMarkup;

/**
 Called when the interstitial should be displayed.

 This message is sent sometime after an interstitial has been successfully loaded, as a result of
 code calling @c showFromViewController: on an instance of @c MPInterstitialAdController. Your
 implementation of this method should present the fullscreen ad from the specified view controller.

 If you decide to opt out of automatic impression tracking (@c enableAutomaticImpressionTracking),
 you should place your manual calls to @c trackImpression method of @c MPFullscreenAdAdapterDelegate.
 to ensure correct metrics.

 @param viewController The controller to use to present the interstitial modally.
 */
- (void)presentAdFromViewController:(UIViewController *)viewController;

/**
 Override this method to handle when an ad was played for this adapter's network, but under a
 different ad unit ID.

 Due to the way ad mediation works, two ad units may load the same ad network for displaying ads.
 When one ad unit plays an ad, the other ad unit may need to update its state and notify the
 application an ad may no longer be available as it may have already played. If an ad becomes
 unavailable for this adapter, call @c fullscreenAdAdapterDidExpire: of
 @c MPFullscreenAdAdapterDelegate to notify the application that an ad is no longer available.

 This method will only be called if your adapter has reported that an ad had successfully loaded.
 The default implementation of this method does nothing.
 Subclasses must override this method and implement code to handle when the adapter is no longer
 needed by the ad reward system.
 */
- (void)handleDidPlayAd;

/**
 Override this method to handle when the adapter is no longer needed by the ad reward system.

 This method is called once the ad reward system no longer references your adapter. This method
 is provided as you may have a centralized object holding onto this adapter. If that is the case
 and your centralized object no longer needs the adapter, then you should remove the adapter
 from the centralized object in this method causing the adapter to deallocate.

 Implementation of this method is not necessary if you do not hold any extra references to it.
 @c dealloc will still be called. However, it is expected you will need to override this method to
 prevent memory leaks. It is safe to override with nothing if you believe you will not leak memory.
 */
- (void)handleDidInvalidateAd;

/**
 The @c delegate object to send events to as they occur.

 @c MPFullscreenAdAdapterDelegate defines several methods that you should call in
 order to inform MoPub of the state of your adapter.
 */
@property (nonatomic, weak, readonly) id<MPFullscreenAdAdapterDelegate> delegate;

@end

#pragma mark -

/**
 This is here for backwards compatibility only.

 Third party adapters are no longer required to conform to this protocol.
 */
@protocol MPThirdPartyFullscreenAdAdapter <MPFullscreenAdAdapter>
@end

#pragma mark -

@interface MPFullscreenAdAdapter : NSObject
@end

#pragma mark -

@interface MPFullscreenAdAdapter (MPFullscreenAdAdapter) <MPFullscreenAdAdapter>
@end

NS_ASSUME_NONNULL_END
