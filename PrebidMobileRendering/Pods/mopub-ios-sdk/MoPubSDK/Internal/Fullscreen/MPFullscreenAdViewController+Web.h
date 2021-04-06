//
//  MPFullscreenAdViewController+Web.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPFullscreenAdViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Web view controller without MRAID capability.
 */
@interface MPFullscreenAdViewController (Web)

@property (nonatomic, assign) MPInterstitialOrientationType orientationType; // backing storage at "+Private.h"

@property (nonatomic, weak) id<MPFullscreenAdViewControllerWebAdDelegate> webAdDelegate; // backing storage at "+Private.h"

- (void)loadConfigurationForWebAd:(MPAdConfiguration *)configuration;

#pragma mark - View Controller Life Cycle for Web Ads

/**
 Invoked before `presentViewController:animated:completion:`
 */
- (void)willPresentFullscreenWebAd;

/**
 Invoked in the completion block of `presentViewController:animated:completion:`
 */
- (void)didPresentFullscreenWebAd;

/**
 Invoked before `dismissViewControllerAnimated:completion:`
 */
- (void)willDismissFullscreenWebAd;

/**
 Invoked in the completion block of `dismissViewControllerAnimated:completion:`
 */
- (void)didDismissFullscreenWebAd;

#pragma mark - View Life Cycle for Web Ads

/**
 Invoked in `viewWillAppear:`
 */
- (void)fullscreenWebAdWillAppear;

/**
 Invoked in `viewDidAppear:`
*/
- (void)fullscreenWebAdDidAppear;

/**
 Invoked in `viewWillDisappear:`
*/
- (void)fullscreenWebAdWillDisappear;

/**
 Invoked in `viewDidDisappear:`
*/
- (void)fullscreenWebAdDidDisappear;

@end

NS_ASSUME_NONNULL_END
