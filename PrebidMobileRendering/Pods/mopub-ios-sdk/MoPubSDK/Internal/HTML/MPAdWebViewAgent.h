//
//  MPAdWebViewAgent.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdConfiguration.h"
#import "MPWebView.h"

// Forward declarations
@protocol MPAdWebViewAgentDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 Business logic layer for `MPWebView` specifically for HTML ads.
 */
@interface MPAdWebViewAgent : NSObject
/**
 Queries if the web view is allowed to field load requests at this time.
 */
@property (nonatomic, readonly) BOOL isRequestHandlingEnabled;

/**
 Web View instance that the controller is managing.
 */
@property (nonatomic, nullable, strong, readonly) MPWebView *webView;

/**
 Delegate handler for receiving controller events.
 */
@property (nonatomic, nullable, weak) id<MPAdWebViewAgentDelegate> delegate;

#pragma mark - Initialization

/**
 Initializes the controller with the desired initial web view frame size.
 @param frame Initial web view frame size.
 @param delegate Delegate handler for receiving controller events.
 @return An initialized instance.
 */
- (instancetype)initWithWebViewFrame:(CGRect)frame
                            delegate:(id<MPAdWebViewAgentDelegate>)delegate;

#pragma mark - View Lifecycle
/**
 Attempts to load the web view with the specified ad configuration.
 @param configuration Ad configuration to load into the web view.
 */
- (void)loadConfiguration:(MPAdConfiguration *)configuration;

/**
 Signal to the controller that the web view is being shown.
 */
- (void)didAppear;

/**
 Signal to the controller that the web view has been removed from the view hierarchy.
 @note This will end the Viewability tracking session.
 */
- (void)didDisappear;

#pragma mark - Request Handling

/**
 Enables web view request handling.
 */
- (void)enableRequestHandling;

/**
 Disables web view request handling.
 */
- (void)disableRequestHandling;

@end

@protocol MPAdWebViewAgentDelegate <NSObject>
/**
 View Controller used to present modals as a result of a clickthrough.
 */
- (UIViewController *)viewControllerForPresentingModalView;

/**
 Called when the webview has been created and about to load the HTML.
 */
- (void)adSessionStarted:(MPWebView *)webView;

/**
 Customize the HTML content that will be loaded into the webview. This hook is provided for Viewability injection purposes.
 If no customization is required, return the passed in HTML string.
 @param html HTML string that will be loaded into @c webView.
 @param webView The target web view.
 @return The modified HTML string.
 */
- (NSString *)customizeHTML:(NSString *)html inWebView:(MPWebView *)webView;

/**
 The web view has finished loading the HTML.
 @note The creative may not have completed loading at this point.
 */
- (void)adSessionReady:(MPWebView *)ad;

- (void)adDidClose:(MPWebView *)ad;
- (void)adDidLoad:(MPWebView *)ad;
- (void)adDidFailToLoad:(MPWebView *)ad;
- (void)adActionWillBegin:(MPWebView *)ad;
- (void)adActionWillLeaveApplication:(MPWebView *)ad;
- (void)adActionDidFinish:(MPWebView *)ad;
- (void)adWebViewAgentDidReceiveTap:(MPAdWebViewAgent *)aAdWebViewAgent;
@end

NS_ASSUME_NONNULL_END
