/*   Copyright 2017 Prebid.org, Inc.
 
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
#import <XCTest/XCTest.h>
#import "PrebidCache.h"
#import <WebKit/Webkit.h>

@interface PBPrebidCacheTests : XCTestCase <UIWebViewDelegate, WKNavigationDelegate>
@property void (^uiwebviewCompletionHandler)(void);
@property void (^wkwebviewCompletionHandler)(void);
@end

@implementation PBPrebidCacheTests

- (void) testPrebidCacheReturnedCorrectIdsForDFP
{
    NSArray *contents = @[@"0", @"1", @"2"];
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"UIWebView expectation"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"WkWebView expectation"];
    [[PrebidCache globalCache] cacheContents:contents forAdserver:PBPrimaryAdServerDFP withCompletionBlock:^(NSArray *cacheIds) {
        //use cacheIds[0] should retrieve content 0
        //use cacheIds[1] should retrieve content 1
        //use cacheIds[2] should retrieve content 2
        XCTAssertTrue(cacheIds.count == 3);
        NSURL *host = [NSURL URLWithString:@"https://pubads.g.doubleclick.net"];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWebView *uiwebview = [[UIWebView alloc] init];
            uiwebview.delegate = self;
            [uiwebview loadRequest:[NSURLRequest requestWithURL:host]];
            __weak PBPrebidCacheTests *weakSelf = self;
            weakSelf.uiwebviewCompletionHandler = ^{
                NSString *result =[uiwebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"localStorage.getItem('%@')", cacheIds[0]]];
                XCTAssertEqualObjects(@"0", result);
                result =[uiwebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"localStorage.getItem('%@')", cacheIds[1]]];
                 XCTAssertEqualObjects(@"1", result);
                result =[uiwebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"localStorage.getItem('%@')", cacheIds[2]]];
                XCTAssertEqualObjects(@"2", result);
                [expectation1 fulfill];
            };
            WKWebView *wkwebview = [[WKWebView alloc] init];
            wkwebview.navigationDelegate = self;
            [wkwebview loadRequest:[NSURLRequest requestWithURL:host]];
            weakSelf.wkwebviewCompletionHandler = ^{
                [wkwebview evaluateJavaScript:[NSString stringWithFormat:@"localStorage.getItem('%@')", cacheIds[0]] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                     XCTAssertEqualObjects(@"0", result);
                    [wkwebview evaluateJavaScript:[NSString stringWithFormat:@"localStorage.getItem('%@')", cacheIds[1]] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        XCTAssertEqualObjects(@"1", result);
                        [wkwebview evaluateJavaScript:[NSString stringWithFormat:@"localStorage.getItem('%@')", cacheIds[2]] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                            XCTAssertEqualObjects(@"2", result);
                            [expectation2 fulfill];
                        }];
                    }];
                }];
            };
        });
    }];
     [self waitForExpectationsWithTimeout:20.0 handler:nil];
}

- (void) testPrebidCacheReturnedCorrectIdsForMoPub
{
    NSArray *contents = @[@"0", @"1", @"2"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"WkWebView expectation"];
    [[PrebidCache globalCache] cacheContents:contents forAdserver:PBPrimaryAdServerMoPub withCompletionBlock:^(NSArray *cacheIds) {
        //use cacheIds[0] should retrieve content 0
        //use cacheIds[1] should retrieve content 1
        //use cacheIds[2] should retrieve content 2
        XCTAssertTrue(cacheIds.count == 3);
        NSURL *host = [NSURL URLWithString:@"https://ads.mopub.com"];
        dispatch_async(dispatch_get_main_queue(), ^{
            WKWebView *wkwebview = [[WKWebView alloc] init];
            wkwebview.navigationDelegate = self;
            [wkwebview loadRequest:[NSURLRequest requestWithURL:host]];
            __weak PBPrebidCacheTests *weakSelf = self;
            weakSelf.wkwebviewCompletionHandler = ^{
                [wkwebview evaluateJavaScript:[NSString stringWithFormat:@"localStorage.getItem('%@')", cacheIds[0]] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                    XCTAssertEqualObjects(@"0", result);
                    [wkwebview evaluateJavaScript:[NSString stringWithFormat:@"localStorage.getItem('%@')", cacheIds[1]] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        XCTAssertEqualObjects(@"1", result);
                        [wkwebview evaluateJavaScript:[NSString stringWithFormat:@"localStorage.getItem('%@')", cacheIds[2]] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                            XCTAssertEqualObjects(@"2", result);
                            [expectation2 fulfill];
                        }];
                    }];
                }];
            };
        });
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.uiwebviewCompletionHandler();
}

- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.wkwebviewCompletionHandler();
}
@end
