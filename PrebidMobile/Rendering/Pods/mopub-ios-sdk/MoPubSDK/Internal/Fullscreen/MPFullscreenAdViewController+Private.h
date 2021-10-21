//
//  MPFullscreenAdViewController+Private.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdContainerView.h"
#import "MPAdWebViewAgent.h"
#import "MRController.h"
#import "MPFullscreenAdViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdViewController ()

#pragma mark - Common Properties

@property (nonatomic, assign) MPAdContentType adContentType;
@property (nonatomic, strong) MPAdContainerView *adContainerView;

#pragma mark - (Web) Properties

@property (nonatomic, assign) MPInterstitialOrientationType orientationType;
@property (nonatomic, strong) MPWebView *webView;
@property (nonatomic, strong) MPAdWebViewAgent *_webViewAgent;

#pragma mark - (MRAIDWeb) Properties

@property (nonatomic, strong) MRController *mraidController;
@property (nonatomic, assign) UIInterfaceOrientationMask _supportedOrientationMask; // custom getter and setter
@property (nonatomic, weak) id<MPFullscreenAdViewControllerWebAdDelegate> webAdDelegate;

#pragma mark - (Video) Properties

@property (nonatomic, weak) id<MPVideoPlayerDelegate> videoPlayerDelegate;

@end

NS_ASSUME_NONNULL_END
