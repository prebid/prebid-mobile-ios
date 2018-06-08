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

@interface PrebidCacheOperation : NSOperation <UIWebViewDelegate, WKNavigationDelegate>
{
    BOOL executing;
    BOOL finished;
}
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
@property NSString* htmlToLoad;

- (instancetype)initWithHTMLLoad: (NSString *) htmlToLoad;
@end

@interface PrebidCacheOperation()
@end
@implementation PrebidCacheOperation
- (instancetype)initWithHTMLLoad:(NSString *)htmlToLoad
{
    if (self = [super init]) {
        self.htmlToLoad = htmlToLoad;
        executing = NO;
        finished = NO;
        _dfpHost = [NSURL URLWithString:@"http://pubads.g.doubleclick.net"];
        _dfpSecuredHost = [NSURL URLWithString:@"https://pubads.g.doubleclick.net"];
        _mopubHost = [NSURL URLWithString:@"http://ads.mopub.com"];
        _mopubSecuredHost = [NSURL URLWithString:@"https://ads.mopub.com"];
        
        if (!_uiwebviewCacheForDFP) {
            _uiwebviewCacheForDFP = [[UIWebView alloc] init];
            _uiwebviewCacheForDFP.frame = CGRectZero;
            _uiwebviewCacheForDFP.delegate = self;
        }
        if (!_wkwebviewCacheForDFP) {
            _wkwebviewCacheForDFP = [[WKWebView alloc] init];
            _wkwebviewCacheForDFP.frame = CGRectZero;
            _wkwebviewCacheForDFP.navigationDelegate = self;
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
        _loadingCount = 8;
    }
    return self;
}

-(void)start
{
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

-(void)main
{
    //This is the method that will do the work
    @try {
        // attach _wkwebviewCache to current top view to be able to load javascript
        dispatch_async(dispatch_get_main_queue(), ^{
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
            [self.uiwebviewCacheForDFP loadHTMLString:self.htmlToLoad baseURL:self.dfpHost];
            [self.wkwebviewCacheForDFP loadHTMLString:self.htmlToLoad baseURL:self.dfpHost];
            [self.uiwebviewSecuredCacheForDFP loadHTMLString:self.htmlToLoad baseURL:self.dfpSecuredHost];
            [self.wkwebviewSecuredCacheForDFP loadHTMLString:self.htmlToLoad baseURL:self.dfpSecuredHost];
            [self.uiwebviewCacheForMopub loadHTMLString:self.htmlToLoad baseURL:self.mopubHost];
            [self.wkwebviewCacheForMoPub loadHTMLString:self.htmlToLoad baseURL:self.mopubHost];
            [self.uiwebviewSecuredCacheForMoPub loadHTMLString:self.htmlToLoad baseURL:self.mopubSecuredHost];
            [self.wkwebviewSecuredCacheForMoPub loadHTMLString:self.htmlToLoad baseURL:self.mopubSecuredHost];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"Catch the exception %@",[exception description]);
    }
    @finally {
        NSLog(@"Custom Operation - Main Method - Finally block");
    }
}

-(BOOL)isConcurrent
{
    return YES;    //Default is NO so overriding it to return YES;
}

-(BOOL)isExecuting{
    return executing;
}

-(BOOL)isFinished{
    return finished;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _loadingCount--;
    if (_loadingCount == 0) {
        [self finishAndChangeState];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    _loadingCount--;
    if (_loadingCount == 0) {
        [self finishAndChangeState];
    }
}

- (void) finishAndChangeState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.wkwebviewCacheForMoPub removeFromSuperview];
        [self.wkwebviewCacheForDFP removeFromSuperview];
        [self.wkwebviewSecuredCacheForDFP removeFromSuperview];
        [self.wkwebviewSecuredCacheForMoPub removeFromSuperview];
    });
    [self willChangeValueForKey:@"isExecuting"];
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

@end



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
@property NSOperationQueue *cacheQueue;
@end

@implementation PrebidCache

+ (instancetype)globalCache {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        [instance setupQueue];
    });
    
    return instance;
}

-(void) setupQueue
{
    self.cacheQueue = [NSOperationQueue new];;
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

- (void) cacheContents:(NSArray *)contents withCompletionBlock:(void (^)(NSArray *))completionBlock
{
      long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSMutableString *htmlToLoad = [[NSMutableString alloc] init];
    [htmlToLoad appendString:@"<head>"];
    [htmlToLoad appendString:[NSString stringWithFormat:@"<script>var currentTime = %lld;var toBeDeleted = [];for(i = 0; i< localStorage.length; i ++){if(localStorage.key(i).startsWith('Prebid_')) {createdTime = localStorage.key(i).split('_')[2];if (( currentTime - createdTime) > %ld){toBeDeleted.push(localStorage.key(i));}}}for ( i = 0; i< toBeDeleted.length; i ++) {localStorage.removeItem(toBeDeleted[i]);}</script>", milliseconds, (long) expireCacheMilliSeconds]];
    NSMutableArray *cacheIds = [[NSMutableArray alloc] init];
    for (NSString *content in contents) {
        NSString *cacheId = [NSString stringWithFormat:@"Prebid_%@_%lld", [NSString stringWithFormat:@"%08X", arc4random()], milliseconds];
        [cacheIds addObject:cacheId];
        [htmlToLoad appendString:[NSString stringWithFormat:@"<script>localStorage.setItem('%@','%@');</script>", cacheId, content]];
    }
    [htmlToLoad appendString:@"</head>"];
    PrebidCacheOperation *cacheOperation = [[PrebidCacheOperation alloc] initWithHTMLLoad:htmlToLoad];
    cacheOperation.completionBlock = ^{ completionBlock(cacheIds);};
    [self.cacheQueue addOperation:cacheOperation];
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
