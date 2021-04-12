//
//  OXMAdViewManagerDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;
@class UIViewController;

@class OXMAbstractCreative;
@class OXMAdDetails;
@class OXMAdViewManager;
@class OXMInterstitialDisplayProperties;

// This protocol defines the communication from the OXMAdViewManager to the OXMAdView
NS_ASSUME_NONNULL_BEGIN
@protocol OXMAdViewManagerDelegate <NSObject>

@required
- (UIViewController *)viewControllerForModalPresentation;

- (void)adLoaded:(OXMAdDetails *)oxmAdDetails;
- (void)failedToLoad:(NSError *)error;

- (void)adDidComplete;
- (void)adDidDisplay;

- (void)adWasClicked;
- (void)adViewWasClicked;

- (void)adDidExpand;
- (void)adDidCollapse;

- (void)adDidLeaveApp;

- (void)adClickthroughDidClose;

- (void)adDidClose;

@optional
//Only used by OXMBannerView & OXMVideoAdView
// The actual top layer view that displays the ad
- (UIView *)displayView;

//Only used by OXMVideoAdView, OXADisplayView, OXAInterstitialController
//Note: all of them seem to simply return a new object.
//TODO: Verify whether the instantiation of an object should be inside the delegate.
- (OXMInterstitialDisplayProperties *)interstitialDisplayProperties;

- (void)videoAdDidFinish;
- (void)videoAdWasMuted;
- (void)videoAdWasUnmuted;

@end
NS_ASSUME_NONNULL_END

