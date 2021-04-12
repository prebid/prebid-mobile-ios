//
//  OXABannerViewDelegate.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//
NS_ASSUME_NONNULL_BEGIN

@class OXABannerView;
@class UIViewController;
@class NSError;

/*!
 Protocol for interaction with the OXABannerView instance.
 
 All messages are guaranteed to occur on the main thread.
 */
@protocol OXABannerViewDelegate<NSObject>

@required

/** @name Methods */
/*!
 @abstract Asks the delegate for a view controller instance to use for presenting modal views
 as a result of user interaction on an ad. Usual implementation may simply return self,
 if it is view controller class.
 */
- (nullable UIViewController *)bannerViewPresentationController;

@optional

/*!
 @abstract Notifies the delegate that an ad has been successfully loaded and rendered.
 @param bannerView The OXABannerView instance sending the message.
 */
- (void)bannerViewDidReceiveAd:(OXABannerView *)bannerView adSize:(CGSize)adSize;

/*!
 @abstract Notifies the delegate of an error encountered while loading or rendering an ad.
 @param bannerView The OXABannerView instance sending the message.
 @param error The error encountered while attempting to receive or render the
 ad.
 */
- (void)bannerView:(OXABannerView *)bannerView
didFailToReceiveAdWithError:(nullable NSError *)error;

/*!
 @abstract Notifies the delegate whenever current app goes in the background due to user click.
 @param bannerView The OXABannerView instance sending the message.
 */
- (void)bannerViewWillLeaveApplication:(OXABannerView *)bannerView;

/*!
 @abstract Notifies delegate that the banner view will launch a modal
 on top of the current view controller, as a result of user interaction.
 @param bannerView The OXABannerView instance sending the message.
 */
- (void)bannerViewWillPresentModal:(OXABannerView *)bannerView;

/*!
 @abstract Notifies delegate that the banner view has dismissed the modal on top of
 the current view controller.
 @param bannerView The OXABannerView instance sending the message.
 */
- (void)bannerViewDidDismissModal:(OXABannerView *)bannerView;

@end

NS_ASSUME_NONNULL_END
