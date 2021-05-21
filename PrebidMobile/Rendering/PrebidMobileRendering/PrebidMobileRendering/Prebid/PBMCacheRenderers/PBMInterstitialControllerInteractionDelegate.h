//
//  PBMInterstitialControllerInteractionDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBMInterstitialController;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMInterstitialControllerInteractionDelegate <NSObject>

@required

- (void)trackImpressionForInterstitialController:(PBMInterstitialController *)interstitialController;


- (void)interstitialControllerDidClickAd:(PBMInterstitialController *)interstitialController;
- (void)interstitialControllerDidCloseAd:(PBMInterstitialController *)interstitialController;
- (void)interstitialControllerDidLeaveApp:(PBMInterstitialController *)interstitialController;


- (nullable UIViewController *)viewControllerForModalPresentationFrom:(PBMInterstitialController *)interstitialController;

@optional

/// Called after an ad has rendered to the device's screen
- (void)interstitialControllerDidDisplay:(PBMInterstitialController *) interstitialController;

/// Called once an ad has finished displaying all of it's creatives
- (void)interstitialControllerDidComplete:(PBMInterstitialController *) interstitialController;

@end

NS_ASSUME_NONNULL_END
