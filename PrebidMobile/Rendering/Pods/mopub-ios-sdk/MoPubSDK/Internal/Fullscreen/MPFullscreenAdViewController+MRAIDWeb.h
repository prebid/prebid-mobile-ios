//
//  MPFullscreenAdViewController+MRAIDWeb.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdConfiguration.h"
#import "MPFullscreenAdViewController+MPForceableOrientationProtocol.h"
#import "MPFullscreenAdViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Web view controller with MRAID capability.
 */
@interface MPFullscreenAdViewController (MRAIDWeb)

@property (nonatomic, weak) id<MPFullscreenAdViewControllerWebAdDelegate> webAdDelegate; // backing storage at "+Private.h"

- (void)loadConfigurationForMRAIDAd:(MPAdConfiguration *)configuration;

#pragma mark - View Controller Life Cycle for MRAID Web Ads

/**
 Invoked before `presentViewController:animated:completion:`
 */
- (void)willPresentFullscreenMRAIDWebAd;

/**
 Invoked in the completion block of `presentViewController:animated:completion:`
 */
- (void)didPresentFullscreenMRAIDWebAd;

/**
 Invoked before `dismissViewControllerAnimated:completion:`
 */
- (void)willDismissFullscreenMRAIDWebAd;

/**
 Invoked in the completion block of `dismissViewControllerAnimated:completion:`
 */
- (void)didDismissFullscreenMRAIDWebAd;

#pragma mark - View Life Cycle for MRAID Web Ads

/**
 Invoked in `viewWillAppear:`
 */
- (void)fullscreenMRAIDWebAdWillAppear;

/**
 Invoked in `viewDidAppear:`
*/
- (void)fullscreenMRAIDWebAdDidAppear;

/**
 Invoked in `viewWillDisappear:`
*/
- (void)fullscreenMRAIDWebAdWillDisappear;

/**
 Invoked in `viewDidDisappear:`
*/
- (void)fullscreenMRAIDWebAdDidDisappear;
    
@end

NS_ASSUME_NONNULL_END
