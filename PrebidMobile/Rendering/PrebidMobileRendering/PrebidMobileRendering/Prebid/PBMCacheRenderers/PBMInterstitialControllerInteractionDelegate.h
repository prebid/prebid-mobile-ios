//
//  PBMInterstitialControllerInteractionDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InterstitialController;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMInterstitialControllerInteractionDelegate <NSObject>

@required

- (void)trackImpressionForInterstitialController:(InterstitialController *)interstitialController;


- (void)interstitialControllerDidClickAd:(InterstitialController *)interstitialController;
- (void)interstitialControllerDidCloseAd:(InterstitialController *)interstitialController;
- (void)interstitialControllerDidLeaveApp:(InterstitialController *)interstitialController;


- (nullable UIViewController *)viewControllerForModalPresentationFrom:(InterstitialController *)interstitialController;

@optional

/// Called after an ad has rendered to the device's screen
- (void)interstitialControllerDidDisplay:(InterstitialController *) interstitialController;

/// Called once an ad has finished displaying all of it's creatives
- (void)interstitialControllerDidComplete:(InterstitialController *) interstitialController;

@end

NS_ASSUME_NONNULL_END
