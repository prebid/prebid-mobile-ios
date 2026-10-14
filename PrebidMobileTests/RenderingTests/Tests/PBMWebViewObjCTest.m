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
#import <XCTest/XCTest.h>
@import WebKit;

#import "PrebidMobileTests-Swift.h"

@interface PBMWebViewObjCTest : XCTestCase<WKNavigationDelegate>

@property (nonnull, strong) XCTestExpectation* expectationNoNavigation;

@end

@implementation PBMWebViewObjCTest

- (void)testLoadHTMLNil {
    PBMWebView *webView = [PBMWebView new];
    
    self.expectationNoNavigation = [self expectationWithDescription:@"expectationNoNavigation"];
    self.expectationNoNavigation.inverted = YES;
    
    
    [UtilitiesForTesting prepareLogFile];
    
    NSString *html = nil;
    [webView loadHTML:html baseURL:nil injectMraidJs: false];
    
    NSString *log = [PBMLog getLogFileAsString];
    XCTAssertTrue([log rangeOfString:@"Input HTML is nil"].location != NSNotFound);
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    [UtilitiesForTesting releaseLogFile];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    [self.expectationNoNavigation fulfill];
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    [self.expectationNoNavigation fulfill];
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self.expectationNoNavigation fulfill];
}


- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self.expectationNoNavigation fulfill];
}


- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.expectationNoNavigation fulfill];
}


- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    [self.expectationNoNavigation fulfill];
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self.expectationNoNavigation fulfill];
}


- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [self.expectationNoNavigation fulfill];
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    [self.expectationNoNavigation fulfill];
}


- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {
    [self.expectationNoNavigation fulfill];
}

@end
