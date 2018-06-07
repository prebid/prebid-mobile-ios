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

#import "PrebidCache.h"
#import <WebKit/Webkit.h>

static NSInteger expireCacheMilliSeconds = 600000; // expire bids cached longer than 10 minutes

@interface PrebidCache () <UIWebViewDelegate>
@property(nonatomic,copy) NSDictionary* frozenCacheInfo;
@property UIWebView *uiwebviewCacheForDFP;
@property WKWebView *wkwebviewCacheForDFP;
@property UIWebView *uiwebviewSecuredCacheForDFP;
@property WKWebView *wkwebviewSecuredCacheForDFP;
@property UIWebView *uiwebviewCacheForMopub;
@property WKWebView *wkwebviewCacheForMoPub;
@property UIWebView *uiwebviewSecuredCacheForMoPub;
@property WKWebView *wkwebviewSecuredCacheForMoPub;
@property NSURL *dfpHost;
@property NSURL *mopubHost;
@property NSURL *dfpSecuredHost;
@property NSURL *mopubSecuredHost;
@property NSInteger loadingCount;
@end

@implementation PrebidCache

+ (instancetype)globalCache {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        [instance setup];
    });
    
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void) setup
{
    _dfpHost = [NSURL URLWithString:@"http://pubads.g.doubleclick.net"];
    _dfpSecuredHost = [NSURL URLWithString:@"https://pubads.g.doubleclick.net"];
    _mopubHost = [NSURL URLWithString:@"http://ads.mopub.com"];
    _mopubSecuredHost = [NSURL URLWithString:@"https://ads.mopub.com"];

    if (!_uiwebviewCacheForDFP) {
        _uiwebviewCacheForDFP = [[UIWebView alloc] init];
        _uiwebviewCacheForDFP.frame = CGRectZero;
    }
    if (!_wkwebviewCacheForDFP) {
        _wkwebviewCacheForDFP = [[WKWebView alloc] init];
        _wkwebviewCacheForDFP.frame = CGRectZero;
    }
    if (!_uiwebviewSecuredCacheForDFP) {
        _uiwebviewSecuredCacheForDFP = [[UIWebView alloc] init];
        _uiwebviewSecuredCacheForDFP.frame = CGRectZero;
      
    }
    if (!_wkwebviewSecuredCacheForDFP) {
        _wkwebviewSecuredCacheForDFP = [[WKWebView alloc] init];
        _wkwebviewSecuredCacheForDFP.frame = CGRectZero;
    }
    if (!_uiwebviewCacheForMopub) {
        _uiwebviewCacheForMopub = [[UIWebView alloc] init];
        _uiwebviewCacheForMopub.frame = CGRectZero;
    }
    if (!_wkwebviewCacheForMoPub) {
        _wkwebviewCacheForMoPub = [[WKWebView alloc] init];
        _wkwebviewCacheForMoPub.frame = CGRectZero;
    }
    if (!_uiwebviewSecuredCacheForMoPub) {
        _uiwebviewSecuredCacheForMoPub = [[UIWebView alloc] init];
        _uiwebviewSecuredCacheForMoPub.frame = CGRectZero;
    }
    if (!_wkwebviewSecuredCacheForMoPub) {
        _wkwebviewSecuredCacheForMoPub = [[WKWebView alloc] init];
        _wkwebviewSecuredCacheForMoPub.frame = CGRectZero;
    }
}


- (NSString *) cacheContent: (NSString *) content
{
    NSLog(@"Prebid Cache starts caching content");
    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *cacheId = [NSString stringWithFormat:@"Prebid_%@_%lld", [NSString stringWithFormat:@"%08X", arc4random()], milliseconds];
    NSString *htmlLoad = [NSString stringWithFormat:@"<head><script>var currentTime = %lld;var toBeDeleted = [];for(i = 0; i< localStorage.length; i ++){if(localStorage.key(i).startsWith('Prebid_')) {createdTime = localStorage.key(i).split('_')[2];if (( currentTime - createdTime) > %ld){toBeDeleted.push(localStorage.key(i));}}}for ( i = 0; i< toBeDeleted.length; i ++) {localStorage.removeItem(toBeDeleted[i]);}</script><script>localStorage.setItem('%@','%@');</script></head><body></body>",milliseconds, (long) expireCacheMilliSeconds,cacheId,content];
    dispatch_async(dispatch_get_main_queue(), ^{
        // attach _wkwebviewCache to current top view to be able to load javascript
        [self.wkwebviewCacheForMoPub removeFromSuperview];
        [self.wkwebviewCacheForDFP removeFromSuperview];
        [self.wkwebviewSecuredCacheForDFP removeFromSuperview];
        [self.wkwebviewSecuredCacheForMoPub removeFromSuperview];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIView *topView = window.rootViewController.view;
        [topView addSubview:self.wkwebviewCacheForMoPub];
        [topView addSubview:self.wkwebviewCacheForDFP];
        [topView addSubview:self.wkwebviewSecuredCacheForDFP];
        [topView addSubview:self.wkwebviewSecuredCacheForMoPub];
        
        [self.uiwebviewCacheForDFP loadHTMLString:htmlLoad baseURL:self.dfpHost];
        [self.wkwebviewCacheForDFP loadHTMLString:htmlLoad baseURL:self.dfpHost];
        [self.uiwebviewSecuredCacheForDFP loadHTMLString:htmlLoad baseURL:self.dfpSecuredHost];
        [self.wkwebviewSecuredCacheForDFP loadHTMLString:htmlLoad baseURL:self.dfpSecuredHost];
        [self.uiwebviewCacheForMopub loadHTMLString:htmlLoad baseURL:self.mopubHost];
        [self.wkwebviewCacheForMoPub loadHTMLString:htmlLoad baseURL:self.mopubHost];
        [self.uiwebviewSecuredCacheForMoPub loadHTMLString:htmlLoad baseURL:self.mopubSecuredHost];
        [self.wkwebviewSecuredCacheForMoPub loadHTMLString:htmlLoad baseURL:self.mopubSecuredHost];
    });
    return cacheId;
}

- (void)dealloc
{
        [self.wkwebviewCacheForMoPub removeFromSuperview];
        [self.wkwebviewCacheForDFP removeFromSuperview];
        [self.wkwebviewSecuredCacheForDFP removeFromSuperview];
        [self.wkwebviewSecuredCacheForMoPub removeFromSuperview];
}
@end
