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
#import "PBMWebView.h"
#import "PBMWebView+PBMTestExtension.h"
#import "PrebidMobileTests-Swift.h"

@interface PBMWebView (Testable)

- (void)evaluateJavaScript:(NSString *)jsCommand;

@end

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

- (void)testExpandNil {
    PBMWebView *webView = [PBMWebView new];
    webView.internalWebView.navigationDelegate = self;
    
    self.expectationNoNavigation = [self expectationWithDescription:@"expectationNoNavigation"];
    self.expectationNoNavigation.inverted = YES;
    
    [UtilitiesForTesting prepareLogFile];
    
    NSURL *url = nil;
    [webView expand:url];
    
    
    NSString *log = [PBMLog getLogFileAsString];
    XCTAssertTrue([log rangeOfString:@"Could not expand with nil url"].location != NSNotFound);
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    [UtilitiesForTesting releaseLogFile];
}
/*
 - (void)testStringIsMRAIDLinkNil {
 NSString *url = nil;
 XCTAssertFalse([PBMWebView isMRAIDLink:url]);
 }
 */
- (void)testEvaluateJSNil {
    PBMWebView *webView = [PBMWebView new];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    webView.jsEvaluatingCompletion = ^(NSString *command, id jsRes, NSError *error){
        XCTAssertNil(command);
        XCTAssertNil(jsRes);
        XCTAssertNil(error);
        
        [expectation fulfill];
    };
    
    NSString *str = nil;
    [webView evaluateJavaScript:str];

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

#pragma mark - isSafeSubframeNavigationWithTargetFrame

// Real iframe content: has a subframe target, isn't a user tap, and is a plain web URL, inside expanded state.
- (void)testIsSafeSubframeNavigation_AllowsSubframeContentLoad {
    BOOL result = [PBMWebView isSafeSubframeNavigationWithTargetFrame:YES
                                                                isMainFrame:NO
                                                             navigationType:WKNavigationTypeOther
                                                                        url:[NSURL URLWithString:@"https://example.com/widget.html"]
                                                                 isExpanded:YES];
    XCTAssertTrue(result);
}

// Test that iframe navigation is still click-gated when the ad is not expanded, even if it would otherwise qualify as safe content.
- (void)testIsSafeSubframeNavigation_RejectsWhenNotExpanded {
    BOOL result = [PBMWebView isSafeSubframeNavigationWithTargetFrame:YES
                                                                isMainFrame:NO
                                                             navigationType:WKNavigationTypeOther
                                                                        url:[NSURL URLWithString:@"https://example.com/widget.html"]
                                                                 isExpanded:NO];
    XCTAssertFalse(result);
}

// A nil targetFrame represents a popup/new-window navigation, not an iframe, and must stay click-gated.
- (void)testIsSafeSubframeNavigation_RejectsNilTargetFrame {
    BOOL result = [PBMWebView isSafeSubframeNavigationWithTargetFrame:NO
                                                                isMainFrame:NO
                                                             navigationType:WKNavigationTypeOther
                                                                        url:[NSURL URLWithString:@"https://example.com/widget.html"]
                                                                 isExpanded:YES];
    XCTAssertFalse(result);
}

- (void)testIsSafeSubframeNavigation_RejectsMainFrame {
    BOOL result = [PBMWebView isSafeSubframeNavigationWithTargetFrame:YES
                                                                isMainFrame:YES
                                                             navigationType:WKNavigationTypeOther
                                                                        url:[NSURL URLWithString:@"https://example.com/widget.html"]
                                                                 isExpanded:YES];
    XCTAssertFalse(result);
}

- (void)testIsSafeSubframeNavigation_RejectsLinkActivatedSubframeTap {
    BOOL result = [PBMWebView isSafeSubframeNavigationWithTargetFrame:YES
                                                                isMainFrame:NO
                                                             navigationType:WKNavigationTypeLinkActivated
                                                                        url:[NSURL URLWithString:@"https://example.com/widget.html"]
                                                                 isExpanded:YES];
    XCTAssertFalse(result);
}

// Unexpected schemes (e.g. custom/deep-link schemes) must not bypass suppression even from a subframe.
- (void)testIsSafeSubframeNavigation_RejectsUnexpectedScheme {
    BOOL result = [PBMWebView isSafeSubframeNavigationWithTargetFrame:YES
                                                                isMainFrame:NO
                                                             navigationType:WKNavigationTypeOther
                                                                        url:[NSURL URLWithString:@"customscheme://example.com/widget.html"]
                                                                 isExpanded:YES];
    XCTAssertFalse(result);
}

// about:/data:/blob: are common ad-tech iframe patterns (e.g. create an iframe, then document.write into it)
// and, like http(s), WKWebView renders them entirely inline with no possibility of an OS-level hand-off.
- (void)testIsSafeSubframeNavigation_AllowsAboutBlank {
    BOOL result = [PBMWebView isSafeSubframeNavigationWithTargetFrame:YES
                                                                isMainFrame:NO
                                                             navigationType:WKNavigationTypeOther
                                                                        url:[NSURL URLWithString:@"about:blank"]
                                                                 isExpanded:YES];
    XCTAssertTrue(result);
}

- (void)testIsSafeSubframeNavigation_AllowsDataScheme {
    BOOL result = [PBMWebView isSafeSubframeNavigationWithTargetFrame:YES
                                                                isMainFrame:NO
                                                             navigationType:WKNavigationTypeOther
                                                                        url:[NSURL URLWithString:@"data:text/html,<p>hi</p>"]
                                                                 isExpanded:YES];
    XCTAssertTrue(result);
}

- (void)testIsSafeSubframeNavigation_AllowsBlobScheme {
    BOOL result = [PBMWebView isSafeSubframeNavigationWithTargetFrame:YES
                                                                isMainFrame:NO
                                                             navigationType:WKNavigationTypeOther
                                                                        url:[NSURL URLWithString:@"blob:https://example.com/12345"]
                                                                 isExpanded:YES];
    XCTAssertTrue(result);
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
