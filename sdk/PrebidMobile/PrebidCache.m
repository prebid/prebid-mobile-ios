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

static NSInteger expireCacheMilliSeconds = 30000; // expire bids cached longer than 10 minutes

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
@property NSURL *httpHost;
@property NSURL *httpsHost;
@property UIWebView *uiwebviewCache;
@property WKWebView *wkwebviewCache;
@property UIWebView *uiwebviewSecuredCache;
@property WKWebView *wkwebviewSecuredCache;
@property NSString* htmlToLoad;

- (instancetype)initWithHTMLLoad: (NSString *) htmlToLoad withAdserver: (PBPrimaryAdServerType) adserver;
@end

@interface PrebidCacheOperation()
@end
@implementation PrebidCacheOperation
- (instancetype)initWithHTMLLoad:(NSString *)htmlToLoad withAdserver: (PBPrimaryAdServerType) adserver
{
    if (self = [super init]) {
        self.htmlToLoad = htmlToLoad;
        executing = NO;
        finished = NO;
        
        _uiwebviewCache = [[UIWebView alloc] init];
        _uiwebviewCache.frame = CGRectZero;
        _uiwebviewCache.delegate = self;
        _wkwebviewCache = [[WKWebView alloc] init];
        _wkwebviewCache.frame = CGRectZero;
        _wkwebviewCache.navigationDelegate = self;
        _uiwebviewSecuredCache = [[UIWebView alloc] init];
        _uiwebviewSecuredCache.frame = CGRectZero;
        _uiwebviewSecuredCache.delegate = self;
        _wkwebviewSecuredCache = [[WKWebView alloc] init];
        _wkwebviewSecuredCache.frame = CGRectZero;
        _wkwebviewSecuredCache.navigationDelegate = self;
        _loadingCount = 4;
        
        if (adserver == PBPrimaryAdServerDFP) {
            _httpHost = [NSURL URLWithString:@"http://pubads.g.doubleclick.net"];
            _httpsHost = [NSURL URLWithString:@"https://pubads.g.doubleclick.net"];
        } else if (adserver == PBPrimaryAdServerMoPub){
            _httpHost = [NSURL URLWithString:@"http://ads.mopub.com"];
            _httpsHost = [NSURL URLWithString:@"https://ads.mopub.com"];
        } else {
            [self finishAndChangeState]; // TODO: check for a proper handling here
        }
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
            [self.wkwebviewCache removeFromSuperview];
            [self.wkwebviewSecuredCache removeFromSuperview];
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIView *topView = window.rootViewController.view;
            [topView addSubview:self.wkwebviewCacheForMoPub];
            [topView addSubview:self.wkwebviewCacheForDFP];
            [topView addSubview:self.wkwebviewSecuredCacheForDFP];
            [topView addSubview:self.wkwebviewSecuredCacheForMoPub];
            [self.uiwebviewCache loadHTMLString:self.htmlToLoad baseURL:self.httpHost];
            [self.wkwebviewCache loadHTMLString:self.htmlToLoad baseURL:self.httpHost];
            [self.uiwebviewSecuredCache loadHTMLString:self.htmlToLoad baseURL:self.httpsHost];
            [self.wkwebviewSecuredCache loadHTMLString:self.htmlToLoad baseURL:self.httpsHost];
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
        [self.wkwebviewCache removeFromSuperview];
        [self.wkwebviewSecuredCache removeFromSuperview];
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

- (void) cacheContents:(NSArray *)contents forAdserver:(PBPrimaryAdServerType)adserver withCompletionBlock:(void (^)(NSArray *))completionBlock
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
    PrebidCacheOperation *cacheOperation = [[PrebidCacheOperation alloc] initWithHTMLLoad:htmlToLoad withAdserver:adserver];
    cacheOperation.completionBlock = ^{ completionBlock(cacheIds);};
    [self.cacheQueue addOperation:cacheOperation];
}

@end
