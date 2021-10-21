/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMClickthroughBrowserView.h"
#import "PBMClickthroughBrowserView+NavigationHandler.h"
#import "WKWebView+PBMWKWebViewCompatible.h"
#import "PBMConstants.h"
#import "PBMLog.h"
#import "PBMFunctions+Private.h"
#import "PBMMacros.h"

@interface PBMClickthroughBrowserView ()
@property (strong, nonatomic, readwrite, nullable) WKWebView *webView;
@end

// MARK: -

@implementation PBMClickthroughBrowserView {
    __weak id<PBMClickthroughBrowserViewDelegate> _clickThroughBrowserViewDelegate;
}

- (void)setClickThroughBrowserViewDelegate:(id<PBMClickthroughBrowserViewDelegate>)clickThroughBrowserViewDelegate {
    _clickThroughBrowserViewDelegate = clickThroughBrowserViewDelegate;
    self.navigationHandler.clickThroughBrowserViewDelegate = clickThroughBrowserViewDelegate;
}

- (id<PBMClickthroughBrowserViewDelegate>)clickThroughBrowserViewDelegate {
    return _clickThroughBrowserViewDelegate;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    // `WKWebView` does not support `initWithCoder` and must be instantiated manually.
    self.webView = [WKWebView new];
    [self addSubview:self.webView];
    
    self.navigationHandler = [[PBMClickthroughBrowserNavigationHandler alloc] initWithWebView:self.webView];

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
    self.closeButton.accessibilityIdentifier = PBMAccesibility.CloseButtonClickThroughBrowserIdentifier;
    self.closeButton.accessibilityLabel = PBMAccesibility.CloseButtonClickThroughBrowserLabel;
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
        [PBMFunctions attemptToOpen:url];
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
