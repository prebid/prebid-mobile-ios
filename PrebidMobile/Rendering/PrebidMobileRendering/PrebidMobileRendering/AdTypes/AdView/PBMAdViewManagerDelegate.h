//
//  PBMAdViewManagerDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIView;
@class UIViewController;

@class PBMAbstractCreative;
@class PBMAdDetails;
@class PBMAdViewManager;
@class PBMInterstitialDisplayProperties;

// This protocol defines the communication from the PBMAdViewManager to the PBMAdView
NS_ASSUME_NONNULL_BEGIN
@protocol PBMAdViewManagerDelegate <NSObject>

@required
- (nullable UIViewController *)viewControllerForModalPresentation;

- (void)adLoaded:(PBMAdDetails *)pbmAdDetails;
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
//Only used by PBMBannerView & PBMVideoAdView
// The actual top layer view that displays the ad
- (UIView *)displayView;

//Only used by PBMVideoAdView, PBMDisplayView, PBMInterstitialController
//Note: all of them seem to simply return a new object.
//TODO: Verify whether the instantiation of an object should be inside the delegate.
- (PBMInterstitialDisplayProperties *)interstitialDisplayProperties;

- (void)videoAdDidFinish;
- (void)videoAdWasMuted;
- (void)videoAdWasUnmuted;

@end
NS_ASSUME_NONNULL_END

