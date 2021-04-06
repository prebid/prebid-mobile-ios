//
//  OXMWebViewObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OXMWebView.h"
#import "OpenXSDKCoreTests-Swift.h"

@interface OXMWebView (Testable)

- (void)evaluateJavaScript:(NSString *)jsCommand;

@end

@interface OXMWebViewObjCTest : XCTestCase<WKNavigationDelegate>

@property (nonnull, strong) XCTestExpectation* expectationNoNavigation;

@end

@implementation OXMWebViewObjCTest

- (void)testLoadHTMLNil {
    OXMWebView *webView = [OXMWebView new];
    
    self.expectationNoNavigation = [self expectationWithDescription:@"expectationNoNavigation"];
    self.expectationNoNavigation.inverted = YES;
    
    
    [UtilitiesForTesting prepareLogFile];
    
    NSString *html = nil;
    [webView loadHTML:html baseURL:nil injectMraidJs: false];
    
    NSString *log = [OXMLog.singleton getLogFileAsString];
    XCTAssertTrue([log rangeOfString:@"Input HTML is nil"].location != NSNotFound);
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    [UtilitiesForTesting releaseLogFile];
}

- (void)testExpandNil {
    OXMWebView *webView = [OXMWebView new];
    webView.internalWebView.navigationDelegate = self;
    
    self.expectationNoNavigation = [self expectationWithDescription:@"expectationNoNavigation"];
    self.expectationNoNavigation.inverted = YES;
    
    [UtilitiesForTesting prepareLogFile];

    NSURL *url = nil;
    [webView expand:url];
    
    
    NSString *log = [OXMLog.singleton getLogFileAsString];
    XCTAssertTrue([log rangeOfString:@"Could not expand with nil url"].location != NSNotFound);
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
    
    [UtilitiesForTesting releaseLogFile];
}
/*
- (void)testStringIsMRAIDLinkNil {
    NSString *url = nil;
    XCTAssertFalse([OXMWebView isMRAIDLink:url]);
}
*/
- (void)testEvaluateJSNil {
    OXMWebView *webView = [OXMWebView new];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    webView.jsEvaluatingCompletion = ^(NSString *command, id jsRes, NSError *error){
        XCTAssertNil(command);
        XCTAssertNil(jsRes);
        XCTAssertNil(error);
        
        [expectation fulfill];
    };
    
    NSString *str = nil;
    [webView evaluateJavaScript:str];
    
    [self waitForExpectationsWithTimeout:3.0 handler:nil];
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
