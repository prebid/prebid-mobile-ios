//
//  MPInlineAdAdapter.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPInlineAdAdapterDelegate.h"
#import "MPScheduledDeallocationAdAdapter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The MoPub iOS SDK mediates third party Ad Networks using adapters.  The adapters are
 responsible for instantiating and manipulating objects in the third party SDK and translating
 and communicating events from those objects back to the MoPub SDK by notifying a delegate.

 @c MPInlineAdAdapter is a base class for adapters that support banners. By implementing
 subclasses of @c MPInlineAdAdapter you can enable the MoPub SDK to natively support a wide
 variety of third-party ad networks.

 At runtime, the MoPub SDK will find and instantiate an @c MPInlineAdAdapter subclass as needed and
 invoke its @c requestAdWithSize:adapterInfo:adMarkup: method.
 */
@protocol MPInlineAdAdapter <MPScheduledDeallocationAdAdapter>

/** @name Requesting a Banner Ad */

/**
 Called when the MoPub SDK requires a new banner ad.

 When the MoPub SDK receives a response indicating it should load an adapter, it will send
 this message to your adapter class. Your implementation of this method can either load a
 banner ad from a third-party ad network, or execute any application code. It must also notify the
 @c MPInlineAdAdapterDelegate of certain lifecycle events.

 @param size The current size of the parent @c MPAdView.  You should use this information to create
 and request a banner of the appropriate size.

 @param info A dictionary containing additional custom data associated with a given adapter
 request. This data is configurable on the MoPub website, and may be used to pass dynamic information,
 such as publisher IDs.

 @param adMarkup An optional ad markup to use.
 */
- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString * _Nullable)adMarkup;

/** @name Callbacks */

/**
 Called when a banner rotation should occur.

 If @c rotateToOrientation is called on the parent @c MPAdView, it will forward the message to its
 adapter. You can implement this method for third-party ad networks that have special behavior when
 orientation changes happen.

 @param newOrientation The @c UIInterfaceOrientation passed to the @c MPAdView's @c rotateToOrientation method.
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;

/**
 Called when the banner is presented on screen.

 If you decide to opt out of automatic impression tracking via @c enableAutomaticImpressionAndClickTracking,
 you should place your manual calls to @c inlineAdAdapterDidTrackImpression: in this method to ensure correct metrics.
 */
- (void)didDisplayAd;

/** @name Impression and Click Tracking */

/**
 Override to opt out of automatic impression and click tracking.

 By default, the @c MPInlineAdAdapterDelegate will automatically record impressions and clicks in
 response to the appropriate callbacks. You may override this behavior by overriding this property
 to return @c NO.

 @warning **Important**: If you override this, you are responsible for calling the
 @c inlineAdAdapterDidTrackImpression: and @c inlineAdAdapterDidTrackClick: methods on the adapter
 @c delegate. Additionally, you should make sure that these methods are only called **once** per ad.
 */
- (BOOL)enableAutomaticImpressionAndClickTracking;

/**
 An optional dictionary containing extra local data.
 */
@property (nonatomic, copy, nullable) NSDictionary *localExtras;

/** @name Communicating with the MoPub SDK */

/**
 The object of type @c MPInlineAdAdapterDelegate to send messages to as events occur.

 The @c delegate object defines several methods that you should call in order to inform both MoPub
 and the parent @c MPAdView's delegate of the progress of your adapter.
 */
@property (nonatomic, weak, readonly) id<MPInlineAdAdapterDelegate> delegate;

@end

#pragma mark -

/**
 This is here for backwards compatibility only.

 Third party adapters are no longer required to conform to this protocol.
 */
@protocol MPThirdPartyInlineAdAdapter <MPInlineAdAdapter>
@end

#pragma mark -

@interface MPInlineAdAdapter : NSObject
@end

#pragma mark -

@interface MPInlineAdAdapter (MPInlineAdAdapter) <MPInlineAdAdapter>
@end

NS_ASSUME_NONNULL_END
