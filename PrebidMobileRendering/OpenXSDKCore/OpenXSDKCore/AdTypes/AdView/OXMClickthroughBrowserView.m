//
//  OXMClickthroughBrowserView.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMClickthroughBrowserView.h"
#import "OXMClickthroughBrowserView+NavigationHandler.h"
#import "WKWebView+OXMWKWebViewCompatible.h"
#import "OXMConstants.h"
#import "OXMLog.h"
#import "OXMFunctions+Private.h"
#import "OXMMacros.h"

@interface OXMClickthroughBrowserView ()
@property (strong, nonatomic, readwrite, nullable) WKWebView *webView;
@end

// MARK: -

@implementation OXMClickthroughBrowserView {
    __weak id<OXMClickthroughBrowserViewDelegate> _clickThroughBrowserViewDelegate;
}

- (void)setClickThroughBrowserViewDelegate:(id<OXMClickthroughBrowserViewDelegate>)clickThroughBrowserViewDelegate {
    _clickThroughBrowserViewDelegate = clickThroughBrowserViewDelegate;
    self.navigationHandler.clickThroughBrowserViewDelegate = clickThroughBrowserViewDelegate;
}

- (id<OXMClickthroughBrowserViewDelegate>)clickThroughBrowserViewDelegate {
    return _clickThroughBrowserViewDelegate;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    // `WKWebView` does not support `initWithCoder` and must be instantiated manually.
    self.webView = [WKWebView new];
    [self addSubview:self.webView];
    
    self.navigationHandler = [[OXMClickthroughBrowserNavigationHandler alloc] initWithWebView:self.webView];

    self.webView.translatesAutoresizingMaskIntoConstraints = NO;

    // Assign us as the delegate so we can be notified of navigations.
    self.webView.navigationDelegate = self.navigationHandler;

    // The webview's width should match the container width
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.webView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:0];

    // The webview's height should go from the top of the screen to the top of the controls
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.webView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTopMargin
                                                          multiplier:1.0
                                                            constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.webView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.controls
                                                              attribute:NSLayoutAttributeTopMargin
                                                             multiplier:1.0
                                                               constant:0];

    NSArray<NSLayoutConstraint *> *constraints = @[width, top, bottom];
    [self addConstraints:constraints];
    
    //Set accesibility info
    self.closeButton.accessibilityIdentifier = OXMAccesibility.CloseButtonClickThroughBrowserIdentifier;
    self.closeButton.accessibilityLabel = OXMAccesibility.CloseButtonClickThroughBrowserLabel;
}

#pragma mark - IBActions
- (IBAction)backButtonPressed {
    [self.webView goBack];
}

- (IBAction)forwardButtonPressed {
    [self.webView goForward];
}

- (IBAction)refreshButtonPressed {
    [self.webView reload];
}

- (IBAction)externalBrowserButtonPressed {
    NSURL *url = self.webView.URL;
    if (url) {
        [OXMFunctions attemptToOpen:url];
        [self.clickThroughBrowserViewDelegate clickThroughBrowserViewWillLeaveApp];
    }
}

- (IBAction)closeButtonPressed {
    [self.clickThroughBrowserViewDelegate clickThroughBrowserViewCloseButtonTapped];
}

#pragma mark - external interface

- (void)openURL:(NSURL *)url completion:(void (^_Nullable)(BOOL shouldBeDisplayed))completion {
    [self.navigationHandler openURL:url completion:completion];
}

@end
