//
//  MPFullscreenAdViewControllerDelegate.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MPFullscreenAdViewController;
@class MPAdContainerView;
@class MPWebView;

#pragma mark -

/**
 Note: Appear and Disappear events might happen multiple times if a view controller such as a web
 browser view controller is presented on top, and disappearing is not the same as dismissing.
 */
@protocol MPFullscreenAdViewControllerAppearanceDelegate <NSObject>

- (void)fullscreenAdWillAppear:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenAdDidAppear:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenAdWillDisappear:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenAdDidDisappear:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenAdWillDismiss:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenAdDidDismiss:(id<MPFullscreenAdViewController>)fullscreenAdViewController;

@end

#pragma mark -

@protocol MPFullscreenAdViewControllerWebAdDelegate <NSObject>

/**
 Notifies when the Fullscreen web session will start. This will be called before any HTML is loaded into the web view.
 @param fullscreenAdViewController The fullscreen view controller associated with this callback.
 @param containerView The view containing the web view instance that is starting.
 */
- (void)fullscreenAdViewController:(id<MPFullscreenAdViewController>)fullscreenAdViewController webSessionWillStartInView:(MPAdContainerView *)containerView;

/**
 Notifies when the inline web view will load an HTML string into the web view. This provides an injection point for HTML customization.
 @param fullscreenAdViewController The fullscreen view controller associated with this callback.
 @param html The HTML to be loaded into the web view.
 @param webView The web view instance that will be the target of the HTML load.
 @returns The HTML to be loaded into the web view. If no processing is required, just return the passed in @c html
 */
- (NSString *)fullscreenAdViewController:(id<MPFullscreenAdViewController>)fullscreenAdViewController willLoadHTML:(NSString *)html inWebView:(MPWebView *)webView;

/**
 Notifies when the Fullscreen web session is ready. This will be called once the loaded HTML has completed its navigation, and the
 web view is ready to accept further JavaScript commands.
 @param fullscreenAdViewController The fullscreen view controller associated with this callback.
 */
- (void)fullscreenWebAdSessionReady:(id<MPFullscreenAdViewController>)fullscreenAdViewController;

/**
 Notifies when the Fullscreen web creative has successfully loaded.
 */
- (void)fullscreenWebAdDidLoad:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenWebAdDidFailToLoad:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenWebAdDidReceiveTap:(id<MPFullscreenAdViewController>)fullscreenAdViewController;
- (void)fullscreenWebAdWillLeaveApplication:(id<MPFullscreenAdViewController>)fullscreenAdViewController;

@optional

- (void)fullscreenWebAdDidFulfillRewardRequirement:(id<MPFullscreenAdViewController>)fullscreenAdViewController;

@end

NS_ASSUME_NONNULL_END
