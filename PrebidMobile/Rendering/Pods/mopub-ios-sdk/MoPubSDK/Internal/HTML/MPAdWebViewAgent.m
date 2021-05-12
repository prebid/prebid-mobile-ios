//
//  MPAdWebViewAgent.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif
#import "MPAdWebViewAgent.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPAnalyticsTracker.h"
#import "MPLogging.h"
#import "MPUserInteractionGestureRecognizer.h"
#import "NSURL+MPAdditions.h"

@interface MPAdWebViewAgent() <MPAdDestinationDisplayAgentDelegate, MPWebViewDelegate, UIGestureRecognizerDelegate>
// Configuration
@property (nonatomic, nullable, strong) MPAdConfiguration *configuration;

// Clickthrough
@property (nonatomic, strong) id<MPAdDestinationDisplayAgent> clickthroughDestination;

// User interaction
@property (nonatomic, assign) BOOL userInteractedWithWebView;
@property (nonatomic, strong) MPUserInteractionGestureRecognizer *userInteractionRecognizer;

// Web view
@property (nonatomic, assign, readwrite) BOOL isRequestHandlingEnabled;
@property (nonatomic, strong, readwrite) MPWebView *webView;
@property (nonatomic, assign) CGRect webViewFrame;
@end

@implementation MPAdWebViewAgent

#pragma mark - Initialization

- (instancetype)initWithWebViewFrame:(CGRect)frame
                            delegate:(id<MPAdWebViewAgentDelegate>)delegate {
    if (self = [super init]) {
        // Setup internal state
        _clickthroughDestination = [MPAdDestinationDisplayAgent agentWithDelegate:self];
        _configuration = nil;
        _delegate = delegate;

        // Defer creation of web view until load time when more information
        // about the creative is available.
        _isRequestHandlingEnabled = YES;
        _webView = nil;
        _webViewFrame = frame;

        // Configure gesture recognizers to validate real user interaction
        _userInteractedWithWebView = NO;
        _userInteractionRecognizer = ({
            MPUserInteractionGestureRecognizer *recognizer = [[MPUserInteractionGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserInteraction:)];
            recognizer.cancelsTouchesInView = NO;
            recognizer.delegate = self;
            recognizer;
        });
    }

    return self;
}

#pragma mark - View Lifecycle

/**
 Initializes a fresh instance of a web view, replacing any existing instance.
 */
- (void)initializeWebViewWithConfiguration:(MPAdConfiguration *)configuration {
    // Clear out any previous instance of the web view since it's
    // no longer valid.
    if (self.webView != nil) {
        self.webView.delegate = nil;

        [self.webView removeFromSuperview];
        self.webView = nil;
    }

    // Create a fresh web view instance and configure it
    NSArray<WKUserScript *> *scripts = configuration.viewabilityContext.resourcesAsScripts;
    self.webView = [[MPWebView alloc] initWithFrame:self.webViewFrame scripts:scripts];
    self.webView.shouldConformToSafeArea = configuration.isFullscreenAd;
    self.webView.delegate = self;

    // Ignore server configuration size for interstitials. At this point our web view
    // is sized correctly for the device's screen. Currently the server sends down values for a 3.5in
    // screen, and they do not size correctly on a 4in screen.
    if (configuration.isFullscreenAd == false) {
        if ([configuration hasPreferredSize]) {
            CGRect frame = self.webView.frame;
            frame.size.width = configuration.preferredSize.width;
            frame.size.height = configuration.preferredSize.height;
            self.webView.frame = frame;
        }
    }

    [self.webView addGestureRecognizer:self.userInteractionRecognizer];
    [self.webView mp_setScrollable:NO];
}

- (void)loadConfiguration:(MPAdConfiguration *)configuration {
    // Save the configuration to reference tracking information later
    self.configuration = configuration;

    // Create a fresh web view
    [self initializeWebViewWithConfiguration:configuration];

    // Webview has been created and initialized at this point.
    [self.delegate adSessionStarted:self.webView];

    // Perform any HTML customizations now
    NSString *customizedCreativeHTMLString = [self.delegate customizeHTML:configuration.adResponseHTMLString inWebView:self.webView];

    // Load the creative HTML into the web view
    [self.webView loadHTMLString:customizedCreativeHTMLString baseURL:MPAPIEndpoints.baseURL];
}

- (void)didAppear {
    // Invoke the `webviewDidAppear()` JavaScript injected into the creative
    // by the template
    [self.webView evaluateJavaScript:@"webviewDidAppear();" completionHandler:nil];
}

- (void)didDisappear {
    // Invoke the `webviewDidClose()` JavaScript injected into the creative
    // by the template
    [self.webView evaluateJavaScript:@"webviewDidClose();" completionHandler:nil];
}

#pragma mark - Request Handling

- (void)enableRequestHandling {
    self.isRequestHandlingEnabled = YES;
}

- (void)disableRequestHandling {
    self.isRequestHandlingEnabled = NO;

    // Cancel any clickthough navigation immediately.
    [self.clickthroughDestination cancel];
}

#pragma mark - MoPub URL handling

- (void)handleMoPubURL:(NSURL *)url {
    MPLogDebug(@"Loading MoPub URL: %@", url);

    MPMoPubHostCommand command = [url mp_mopubHostCommand];
    switch (command) {
        case MPMoPubHostCommandClose:
            [self.delegate adDidClose:self.webView];
            break;
        case MPMoPubHostCommandFinishLoad:
            [self.delegate adDidLoad:self.webView];
            break;
        case MPMoPubHostCommandFailLoad:
            [self.delegate adDidFailToLoad:self.webView];
            break;
        default:
            MPLogInfo(@"Unsupported MoPub URL: %@", url.absoluteString);
            break;
    }
}

#pragma mark - Clickthrough

/**
 Determines if the given URL navigation is a clickthrough and should be intercepted.
 @param url Target URL.
 @param navigationType Type of navigation used to go to the target URL.
 @return True if the navigation should be intercepted and handled differently; false otherwise.
 */
- (BOOL)isClickthroughUrl:(NSURL *)url navigationType:(WKNavigationType)navigationType {
    // Intercept href links for additional processing
    if (navigationType == WKNavigationTypeLinkActivated) {
        return YES;
    }
    // Intercept clicks when HTML creative uses `window.location()` and `window.open()`
    // and user interaction was detected.
    else if (navigationType == WKNavigationTypeOther && self.userInteractedWithWebView) {
        return YES;
    }

    return NO;
}

/**
 Handles scrubbing the intercepted URL before passing it along to the clickthrough destination.
 @param url Url to handle.
 */
- (void)handleClickthroughUrl:(NSURL *)url {
    // Click tracking is delegated to upstream
    [self.delegate adWebViewAgentDidReceiveTap:self];

    // Direct the URL to the destination handler.
    [self.clickthroughDestination displayDestinationForURL:url skAdNetworkClickthroughData:self.configuration.skAdNetworkClickthroughData];
}

#pragma mark - MPAdDestinationDisplayAgentDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    // Pass through the view controller used to present modals.
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)displayAgentWillPresentModal {
    // The clickthrough destination will present a modal.
    [self.delegate adActionWillBegin:self.webView];
}

- (void)displayAgentWillLeaveApplication {
    // The clickthrough destination will result in an app switch.
    [self.delegate adActionWillLeaveApplication:self.webView];
}

- (void)displayAgentDidDismissModal {
    // The clickthrough modal was closed.
    [self.delegate adActionDidFinish:self.webView];
}

- (MPAdConfiguration *)adConfiguration {
    return self.configuration;
}

#pragma mark - MPUserInteractionGestureRecognizer

- (void)handleUserInteraction:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        // User interaction confirmed.
        self.userInteractedWithWebView = YES;
    }
}

#pragma mark - MPWebViewDelegate

- (BOOL)webView:(MPWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(WKNavigationType)navigationType {
    // Web view request handling has been disabled. Ignore this load.
    if (!self.isRequestHandlingEnabled) {
        return NO;
    }

    // Intercept MoPub deeplink URLs and handle those seperately.
    NSURL *url = request.URL;
    if ([url mp_isMoPubScheme]) {
        [self handleMoPubURL:url];
        return NO;
    }
    // URL navigation is a clickthrough, and must be processed before
    // being sent to the clickthrough destination.
    else if ([self isClickthroughUrl:url navigationType:navigationType]) {
        // Disable intercept without user interaction
        if (!self.userInteractedWithWebView) {
            MPLogInfo(@"Redirect without user interaction detected");
            return NO;
        }

        // Handle the clickthrough
        [self handleClickthroughUrl:url];
        return NO;
    }

    // Don't handle any links without user interaction unless it
    // is a valid http:// or https:// url.
    return self.userInteractedWithWebView || [url mp_isSafeForLoadingWithoutUserAction];
}

- (void)webViewDidFinishLoad:(MPWebView *)webView {
    // Web view has finished loading (including any viewability JavaScript) at this point.
    // Notify that the ad session should start now.
    [self.delegate adSessionReady:webView];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // Allow the gestures to pass through to the views below.
    return YES;
}

@end
