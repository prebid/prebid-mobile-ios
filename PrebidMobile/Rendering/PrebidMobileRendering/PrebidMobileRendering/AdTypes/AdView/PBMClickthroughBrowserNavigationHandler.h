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
