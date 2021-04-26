//
//  PBMUserAgentService.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMUserAgentService.h"
#import "PBMFunctions.h"
#import "PBMNSThreadProtocol.h"
#import <WebKit/WebKit.h>
#import "PBMMacros.h"

#pragma mark - Private Extension

@interface PBMUserAgentService()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *sdkVersion;

@end

#pragma mark - Implementation

@implementation PBMUserAgentService

#pragma mark - Class Properties

+ (instancetype)singleton {
    static PBMUserAgentService *singleton;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [PBMUserAgentService new];
    });

    return singleton;
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
    return [NSString stringWithFormat:@"%@ PrebidMobileRendering/%@", self.userAgent, self.sdkVersion];
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
            PBMLogError(@"%@", error);
        }        
        else if (result) {
            NSString *resultString = [NSString stringWithFormat:@"%@", result];
            self.userAgent = (resultString) ? resultString : @"";
        }
        
        self.webView = nil;
    }];
}

@end
