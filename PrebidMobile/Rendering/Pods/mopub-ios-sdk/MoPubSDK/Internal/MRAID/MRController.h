//
//  MRController.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MRConstants.h"
#import "MPAdContainerView.h"
#import "MPFullscreenAdViewController+MRAIDWeb.h"

@protocol MRControllerDelegate;
@class MPAdConfiguration;
@class CLLocation;
@class MPWebView;

/**
 The `MRController` class is used to load and interact with MRAID ads.
 It contains two MRAID ad views and uses a separate `MRBridge` to
 communicate to each view. `MRController` handles view-related MRAID
 native calls such as expand(), resize(), close(), and open().
 */
@interface MRController : NSObject
@property (nonatomic, readonly) MPAdContainerView *mraidAdView;
@property (nonatomic, weak) id<MRControllerDelegate> delegate;
@property (nonatomic, weak) id<MPCountdownTimerDelegate> countdownTimerDelegate;

- (instancetype)initWithAdViewFrame:(CGRect)adViewFrame
              supportedOrientations:(MPInterstitialOrientationType)orientationType
                    adPlacementType:(MRAdViewPlacementType)placementType
                           delegate:(id<MRControllerDelegate>)delegate;

/**
 Use this to load a regular MRAID ad.
 */
- (void)loadAdWithConfiguration:(MPAdConfiguration *)configuration;

/**
 Use this to load a VAST video companion MRAID ad.
 */
- (void)loadVASTCompanionAd:(NSString *)companionAdHTML;
- (void)loadVASTCompanionAdUrl:(NSURL *)companionAdUrl;

- (void)handleMRAIDInterstitialWillPresentWithViewController:(MPFullscreenAdViewController *)viewController;
- (void)handleMRAIDInterstitialDidPresentWithViewController:(MPFullscreenAdViewController *)viewController;
- (void)enableRequestHandling;
- (void)disableRequestHandling;

/**
 When a click-through happens, do not open a web browser.
 Note: `MRControllerDelegate.adDidReceiveClickthrough:` is still triggered. It's the delegate's
 responsibility to open a web browser when click-through happens.
 */
- (void)disableClickthroughWebBrowser;

/**
 Evaluate the Javascript code "webviewDidAppear();" in the MRAID web view.
 */
- (void)triggerWebviewDidAppear;

@end

/**
 The `MRControllerDelegate` will relay specific events such as ad loading to
 the object that implements the delegate. It also requires information
 such as adUnitId, adConfiguation, and location in order to use its
 ad alert manager.
 **/
@protocol MRControllerDelegate <NSObject>

#pragma mark - Required

@required

// Retrieves the view controller from which modal views should be presented.
- (UIViewController *)viewControllerForPresentingMRAIDModalView;

// Called when the ad is about to display modal content (thus taking over the screen).
- (void)appShouldSuspendForMRAIDAd:(MPAdContainerView *)adView;

// Called when the ad has dismissed any modal content (removing any on-screen takeovers).
- (void)appShouldResumeFromMRAIDAd:(MPAdContainerView *)adView;

/**
 Customize the HTML content that will be loaded into the webview. This hook is provided for Viewability injection purposes.
 If no customization is required, return the passed in HTML string.
 @param html HTML string that will be loaded into @c webView.
 @param webView The target web view.
 @param adView The MRAID container of the web view.
 @return The modified HTML string.
 */
- (NSString *)customizeHTML:(NSString *)html inWebView:(MPWebView *)webView forContainerView:(MPAdContainerView *)adView;

#pragma mark - Optional

@optional

// Called when the webview has been created and about to load the HTML.
- (void)mraidWebSessionStarted:(MPAdContainerView *)adView;

// Called when the webview has successfully finished loading the HTML.
- (void)mraidWebSessionReady:(MPAdContainerView *)adView;

// Called when the ad loads successfully.
- (void)mraidAdDidLoad:(MPAdContainerView *)adView;

// Called when the ad fails to load.
- (void)mraidAdDidFailToLoad:(MPAdContainerView *)adView;

// Called just before the ad closes.
- (void)mraidAdWillClose:(MPAdContainerView *)adView;

// Called just after the ad has closed.
- (void)mraidAdDidClose:(MPAdContainerView *)adView;

// Called when click-throught happens.
- (void)mraidAdDidReceiveClickthrough:(NSURL *)url;

// Called when a user would be taken out of the application context.
- (void)mraidAdWillLeaveApplication;

// Called after the rewarded ad finishes
- (void)mraidAdDidFulflilRewardRequirement;

// Called just before the ad will expand or resize
- (void)mraidAdWillExpand:(MPAdContainerView *)adView;

// Called after the ad collapsed from an expanded or resized state
- (void)mraidAdDidCollapse:(MPAdContainerView *)adView;

@end
