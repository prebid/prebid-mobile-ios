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

#import "PBMClickthroughBrowserNavigationHandler.h"
#import "PBMDeepLinkPlusHelper.h"
#import "PBMConstants.h"
#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"
#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@interface PBMClickthroughBrowserNavigationHandler ()
@property (nonatomic, weak, readonly, nullable) id<PBMWKWebViewCompatible> webView;
@property (nonatomic, strong, nullable) void (^loadingFinishedBlock)(BOOL shouldBeDisplayed);
@property (nonatomic, assign) NSInteger expectedFailuresCount;
@end

// MARK: -

@implementation PBMClickthroughBrowserNavigationHandler

- (instancetype)initWithWebView:(id<PBMWKWebViewCompatible>)webView {
    if(!(self = [super init])) {
        return nil;
    }
    _webView = webView;
    return self;
}

// MARK: - external interface

- (void)openURL:(NSURL *)url completion:(void (^_Nullable)(BOOL shouldBeDisplayed))completion {
    self.loadingFinishedBlock = completion;
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

// MARK: - WKNavigationDelegate

- (void)webView:(id<PBMWKWebViewCompatible>)webView decidePolicyForNavigationAction:(id<PBMWKNavigationActionCompatible>)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    PBMLogWhereAmI();

    //Get the URL
    NSURL *url = navigationAction.request.URL;
    if (!url) {
        PBMLogError(@"No url for navigation");
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    //Get the URL's scheme
    NSString *scheme = url.scheme;
    if (!scheme) {
        //Assume no scheme means http and allow it to load.
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    //deeplink+ scheme handling
    if ([PBMDeepLinkPlusHelper isDeepLinkPlusURL:url]) {
        void (^completion)(BOOL shouldBeDisplayed) = self.loadingFinishedBlock;
        self.loadingFinishedBlock = nil;
        
        @weakify(self);
        [PBMDeepLinkPlusHelper tryHandleDeepLinkPlus:url completion: ^(BOOL visited, NSURL *fallbackURL, NSArray<NSURL *> *trackingURLs) {
            @strongify(self);
            if (visited || fallbackURL == nil) {
                // already visited, or nowhere to redirect to
                decisionHandler(WKNavigationActionPolicyCancel);
                
                if (completion != nil) {
                    completion(NO);
                }
            } else {
                self.expectedFailuresCount++; // ignore first failure
                decisionHandler(WKNavigationActionPolicyCancel);
                
                [self openURL:fallbackURL completion:completion];
                [PBMDeepLinkPlusHelper visitTrackingURLs:trackingURLs];
            }
        }];
        return;
    }

    //Check if this scheme is one of the app store/itunes schemes.
    //WKWebview doesn't support those schemes and they will need to be handled by UIApplication.
    if ([PBMConstants.urlSchemesForAppStoreAndITunes containsObject:scheme]) {
        
        // Cancel navigation since we're handling it manually.
        decisionHandler(WKNavigationActionPolicyCancel);
        
        // Open the URL outside of the app
        [PBMFunctions attemptToOpen:url];
        
        // Notify the delegate we left the app.
        [self.clickThroughBrowserViewDelegate clickThroughBrowserViewWillLeaveApp];
        
        // Act as though we also tapped the close button. This will close the window.
        [self.clickThroughBrowserViewDelegate clickThroughBrowserViewCloseButtonTapped];
        return;
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

#ifdef DEBUG
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    [PBMFunctions checkCertificateChallenge:challenge completionHandler:completionHandler];
}
#endif

- (void)reportLoadingFinishedAndShouldDisplay:(BOOL)shouldDisplay {
    if (!shouldDisplay && self.expectedFailuresCount > 0) {
        self.expectedFailuresCount--;
    } else {
        void (^completion)(BOOL shouldBeDisplayed) = self.loadingFinishedBlock;
        self.loadingFinishedBlock = nil;
        if (completion != nil) {
            completion(shouldDisplay);
        }
    }
}

- (void)webView:(id<PBMWKWebViewCompatible>)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(nonnull NSError *)error {
    [self reportLoadingFinishedAndShouldDisplay:NO];
}

- (void)webView:(id<PBMWKWebViewCompatible>)webView didFailNavigation:(WKNavigation *)navigation {
    [self reportLoadingFinishedAndShouldDisplay:NO];
}

- (void)webView:(id<PBMWKWebViewCompatible>)webView didCommitNavigation:(WKNavigation *)navigation {
    [self reportLoadingFinishedAndShouldDisplay:YES];
}

@end
