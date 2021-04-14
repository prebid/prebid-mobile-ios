//
//  OXAInterstitialControllerInteractionDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OXAInterstitialController;

NS_ASSUME_NONNULL_BEGIN

@protocol OXAInterstitialControllerInteractionDelegate <NSObject>

@required

- (void)trackImpressionForInterstitialController:(OXAInterstitialController *)interstitialController;


- (void)interstitialControllerDidClickAd:(OXAInterstitialController *)interstitialController;
- (void)interstitialControllerDidCloseAd:(OXAInterstitialController *)interstitialController;
- (void)interstitialControllerDidLeaveApp:(OXAInterstitialController *)interstitialController;


- (UIViewController *)viewControllerForModalPresentationFrom:(OXAInterstitialController *)interstitialController;

@optional

/// Called after an ad has rendered to the device's screen
- (void)interstitialControllerDidDisplay:(OXAInterstitialController *) interstitialController;

/// Called once an ad has finished displaying all of it's creatives
- (void)interstitialControllerDidComplete:(OXAInterstitialController *) interstitialController;

@end

NS_ASSUME_NONNULL_END
