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
#import "PBLogging.h"
#import <WebKit/Webkit.h>

static NSInteger expireCacheMilliSeconds = 270000; // expire bids cached longer than 4.5 minutes (console stores them for the same time...)

static NSString *const kPBAppTransportSecurityDictionaryKey = @"NSAppTransportSecurity";
static NSString *const kPBAppTransportSecurityAllowsArbitraryLoadsKey = @"NSAllowsArbitraryLoads";

@interface PrebidCacheOperation : NSOperation <UIWebViewDelegate, WKNavigationDelegate>
{
    BOOL executing;
    BOOL finished;
}

@property NSInteger loadingCount;

@property NSURL *httpsHost;

@property UIWebView *uiwebviewCache;
@property WKWebView *wkwebviewCache;

@property NSString* htmlToLoad;
@property NSMutableArray *cacheIds;
@property (nonnull) void (^sendCacheIds)(NSError *, NSArray *);

- (instancetype)initWithContentsToLoad: (NSArray *)contents withAdserver: (PBPrimaryAdServerType) adserver withCompletionHandler: (void (^) (NSError *, NSArray *)) completionBlock;
@end

@implementation PrebidCacheOperation

- (instancetype)initWithContentsToLoad: (NSArray *)contents withAdserver: (PBPrimaryAdServerType) adserver withCompletionHandler:(void (^)(NSError *, NSArray *))completionBlock
{
    
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        if (contents == nil || contents.count == 0) {
            self.sendCacheIds = completionBlock;
            [self finishAndChangeState];
        } else {
            long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
            NSMutableString *htmlToLoad = [[NSMutableString alloc] init];
            [htmlToLoad appendString:@"<head>"];
            NSString *scriptString = [NSString stringWithFormat:@"<script>var currentTime = %lld;var toBeDeleted = [];for(i = 0; i< localStorage.length; i ++){if(localStorage.key(i).startsWith('Prebid_')) {createdTime = localStorage.key(i).split('_')[2];if (( currentTime - createdTime) > %ld){toBeDeleted.push(localStorage.key(i));}}}for ( i = 0; i< toBeDeleted.length; i ++) {localStorage.removeItem(toBeDeleted[i]);}</script>", milliseconds, (long) expireCacheMilliSeconds];
            [htmlToLoad appendString:scriptString];
            self.cacheIds = [[NSMutableArray alloc] init];
            for (NSString *content in contents) {
                NSString *cacheId = [NSString stringWithFormat:@"Prebid_%@_%lld", [NSString stringWithFormat:@"%08X", arc4random()], milliseconds];
                [self.cacheIds addObject:cacheId];
                [htmlToLoad appendString:[NSString stringWithFormat:@"<script>localStorage.setItem('%@','%@');</script>", cacheId, content]];
            }
            [htmlToLoad appendString:@"</head>"];
            self.htmlToLoad = htmlToLoad;
            self.sendCacheIds = completionBlock;
            _loadingCount = 1;
            _wkwebviewCache = [[WKWebView alloc] init];
            _wkwebviewCache.frame = CGRectZero;
            _wkwebviewCache.navigationDelegate = self;
            
            if (adserver == PBPrimaryAdServerDFP) {
                _httpsHost = [NSURL URLWithString:@"https://pubads.g.doubleclick.net"];
                // We need UIWebView only for DFP & not for MoPub
                _uiwebviewCache = [[UIWebView alloc] init];
                _uiwebviewCache.frame = CGRectZero;
                _uiwebviewCache.delegate = self;
                _loadingCount = 2;
            } else if (adserver == PBPrimaryAdServerMoPub){
                // Grab the ATS dictionary from the Info.plist
                NSDictionary *atsSettingsDictionary = [NSBundle mainBundle].infoDictionary[kPBAppTransportSecurityDictionaryKey];
                if ([atsSettingsDictionary[kPBAppTransportSecurityAllowsArbitraryLoadsKey] boolValue]) {
                    _httpsHost = [NSURL URLWithString:@"http://ads.mopub.com"];
                } else {
                    _httpsHost = [NSURL URLWithString:@"https://ads.mopub.com"];
                }
            } else {
                [self finishAndChangeState]; // TODO: check for a proper handling here
            }
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
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.wkwebviewCache removeFromSuperview];
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            [window addSubview:self.wkwebviewCache];
            if(self.uiwebviewCache != nil){
                [self.uiwebviewCache loadHTMLString:self.htmlToLoad baseURL:self.httpsHost];
            }
            [self.wkwebviewCache loadHTMLString:self.htmlToLoad baseURL:self.httpsHost];
        });
    }
    @catch (NSException *exception) {
        PBLogDebug(@"Catch the exception %@",[exception description]);
    }
    @finally {
        PBLogDebug(@"Cache Operation - Main Method - Finally block");
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
    self.loadingCount--;
    if (self.loadingCount == 0) {
        [self finishAndChangeState];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.loadingCount--;
    if (self.loadingCount == 0) {
        [self finishAndChangeState];
    }
}

- (void) finishAndChangeState
{
    
    __weak PrebidCacheOperation *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong PrebidCacheOperation *strongSelf = weakSelf;
        
        [strongSelf.wkwebviewCache setNavigationDelegate:nil];
        [strongSelf.wkwebviewCache setUIDelegate:nil];
        
        [strongSelf.wkwebviewCache removeFromSuperview];
        strongSelf.wkwebviewCache = nil;
        strongSelf.uiwebviewCache = nil;
        if(self.cacheIds != nil && self.cacheIds.count>0){
            if (strongSelf.sendCacheIds != nil) {
                strongSelf.sendCacheIds(nil, strongSelf.cacheIds);
            }
        } else {
            if (strongSelf.sendCacheIds !=nil) {
                strongSelf.sendCacheIds([NSError errorWithDomain:@"org.prebid" code:0 userInfo:nil ], nil);
            }
        }
        [strongSelf willChangeValueForKey:@"isExecuting"];
        strongSelf->executing = NO;
        [strongSelf didChangeValueForKey:@"isExecuting"];
        [strongSelf willChangeValueForKey:@"isFinished"];
        strongSelf->finished = YES;
        [strongSelf didChangeValueForKey:@"isFinished"];
        
    });
}

@end

@interface PrebidCache ()
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
    self.cacheQueue = [NSOperationQueue new];
}

- (void) cacheContents:(NSArray *)contents forAdserver:(PBPrimaryAdServerType)adserver withCompletionBlock:(void (^)(NSError *, NSArray *))completionBlock
{
    
    PrebidCacheOperation *cacheOperation = [[PrebidCacheOperation alloc] initWithContentsToLoad:contents withAdserver:adserver withCompletionHandler:completionBlock];
    [self.cacheQueue addOperation:cacheOperation];
}



@end
