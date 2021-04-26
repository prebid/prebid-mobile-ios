//
//  PBMWebViewObjCTest.m
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PBMWebView.h"
#import "PrebidMobileRenderingTests-Swift.h"

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
    
    NSString *log = [PBMLog.singleton getLogFileAsString];
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
    
    
    NSString *log = [PBMLog.singleton getLogFileAsString];
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
