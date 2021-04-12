//
//  OXMClickthroughBrowserNavigationHandler.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMWKWebViewCompatible.h"
#import "OXMWKNavigationActionCompatible.h"
#import <WebKit/WebKit.h>
#import "OXMClickthroughBrowserViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXMClickthroughBrowserNavigationHandler : NSObject <WKNavigationDelegate>

@property (nonatomic, weak, nullable) id<OXMClickthroughBrowserViewDelegate> clickThroughBrowserViewDelegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithWebView:(id<OXMWKWebViewCompatible>)webView NS_DESIGNATED_INITIALIZER;

- (void)openURL:(NSURL *)url completion:(void (^_Nullable)(BOOL shouldBeDisplayed))completion;

- (void)webView:(id<OXMWKWebViewCompatible>)webView decidePolicyForNavigationAction:(nullable id<OXMWKNavigationActionCompatible>)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

- (void)webView:(id<OXMWKWebViewCompatible>)webView didFailProvisionalNavigation:(nullable WKNavigation *)navigation withError:(nonnull NSError *)error;

- (void)webView:(id<OXMWKWebViewCompatible>)webView didFailNavigation:(nullable WKNavigation *)navigation;
- (void)webView:(id<OXMWKWebViewCompatible>)webView didCommitNavigation:(nullable WKNavigation *)navigation;

@end

NS_ASSUME_NONNULL_END
