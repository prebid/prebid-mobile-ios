//
//  OXMUserAgentService.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMUserAgentService.h"
#import "OXMFunctions.h"
#import "OXMNSThreadProtocol.h"
#import <WebKit/WebKit.h>
#import "OXMMacros.h"

#pragma mark - Private Extension

@interface OXMUserAgentService()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *sdkVersion;

@end

#pragma mark - Implementation

@implementation OXMUserAgentService

#pragma mark - Class Properties

+ (instancetype)singleton {
    static OXMUserAgentService *singleton;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [OXMUserAgentService new];
    });

    return singleton;
}

#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        self.sdkVersion = [OXMFunctions sdkVersion];
        OXMAssert(self.sdkVersion);
        self.userAgent = @"";
        [self setUserAgent];
    }
    return self;
}

#pragma mark - Public Methods

- (nonnull NSString *)getFullUserAgent {
    return [NSString stringWithFormat:@"%@ OpenXSDK/%@", self.userAgent, self.sdkVersion];
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

- (void)setUserAgentInThread:(id<OXMNSThreadProtocol>)thread {
    if (!thread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUserAgentInThread:thread];
        });
        return;
    }
    [self generateUserAgent];
}

- (void)generateUserAgent {
    @weakify(self);
    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        @strongify(self);
        
        if (error) {
            OXMLogError(@"%@", error);
        }        
        else if (result) {
            NSString *resultString = [NSString stringWithFormat:@"%@", result];
            self.userAgent = (resultString) ? resultString : @"";
        }
        
        self.webView = nil;
    }];
}

@end
