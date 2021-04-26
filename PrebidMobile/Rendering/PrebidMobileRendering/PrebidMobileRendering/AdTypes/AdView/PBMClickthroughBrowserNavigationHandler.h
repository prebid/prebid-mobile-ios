//
//  PBMClickthroughBrowserNavigationHandler.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMWKWebViewCompatible.h"
#import "PBMWKNavigationActionCompatible.h"
#import <WebKit/WebKit.h>
#import "PBMClickthroughBrowserViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMClickthroughBrowserNavigationHandler : NSObject <WKNavigationDelegate>

@property (nonatomic, weak, nullable) id<PBMClickthroughBrowserViewDelegate> clickThroughBrowserViewDelegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithWebView:(id<PBMWKWebViewCompatible>)webView NS_DESIGNATED_INITIALIZER;

- (void)openURL:(NSURL *)url completion:(void (^_Nullable)(BOOL shouldBeDisplayed))completion;

- (void)webView:(id<PBMWKWebViewCompatible>)webView decidePolicyForNavigationAction:(nullable id<PBMWKNavigationActionCompatible>)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

- (void)webView:(id<PBMWKWebViewCompatible>)webView didFailProvisionalNavigation:(nullable WKNavigation *)navigation withError:(nonnull NSError *)error;

- (void)webView:(id<PBMWKWebViewCompatible>)webView didFailNavigation:(nullable WKNavigation *)navigation;
- (void)webView:(id<PBMWKWebViewCompatible>)webView didCommitNavigation:(nullable WKNavigation *)navigation;

@end

NS_ASSUME_NONNULL_END
