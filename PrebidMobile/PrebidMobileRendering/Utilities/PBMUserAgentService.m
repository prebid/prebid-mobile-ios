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

#import "PBMUserAgentService.h"
#import "PBMFunctions.h"
#import "PBMNSThreadProtocol.h"
#import <WebKit/WebKit.h>
#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Private Extension

@interface PBMUserAgentService()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *sdkVersion;

@end

#pragma mark - Implementation

@implementation PBMUserAgentService

#pragma mark - Class Properties

+ (nonnull instancetype)shared {
    static PBMUserAgentService *shared;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PBMUserAgentService alloc] init];
    });

    return shared;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        self.sdkVersion = [PBMFunctions sdkVersion];
        PBMAssert(self.sdkVersion);
        self.userAgent = @"";
        [self setUserAgent];
    }
    return self;
}

#pragma mark - Public Methods

- (nonnull NSString *)getFullUserAgent {
    return [NSString stringWithFormat:@"%@", self.userAgent];
}

#pragma mark - Private Methods

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [WKWebView new];
    }
    return _webView;
}

- (void)setUserAgent {
    [self setUserAgentInThread:[NSThread currentThread]];
}

- (void)setUserAgentInThread:(id<PBMNSThreadProtocol>)thread {
    if (!thread.isMainThread) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setUserAgent];
        });
        return;
    }
    [self generateUserAgent];
}

- (void)generateUserAgent {
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *resultString = [NSString stringWithFormat:@"%@", [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]];
    self.userAgent = (resultString) ? resultString : @"";
}

@end
