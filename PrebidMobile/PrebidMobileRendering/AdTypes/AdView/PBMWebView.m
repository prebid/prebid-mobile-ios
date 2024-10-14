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

@import AVFoundation;
@import AdSupport;

#import <JavaScriptCore/JavaScriptCore.h>

#import "PBMAbstractCreative.h"
#import "PBMCreativeModel.h"
#import "PBMError.h"
#import "PBMFunctions+Private.h"
#import "PBMInterstitialDisplayProperties.h"
#import "PBMLocationManager.h"
#import "PBMMRAIDController.h"
#import "PBMMRAIDJavascriptCommands.h"
#import "PBMMacros.h"
#import "PBMNSThreadProtocol.h"
#import "PBMOpenMeasurementSession.h"
#import "PBMORTB.h"
#import "PBMTouchDownRecognizer.h"
#import "PBMViewExposure.h"
#import "PBMCreativeViewabilityTracker.h"
#import "PBMWKScriptMessageHandlerLeakAvoider.h"
#import "UIView+PBMExtensions.h"

#import "PBMWebView.h"
#import "PBMWebView+Internal.h"

#import "PBMAdViewManagerDelegate.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Constants

static NSString * const PBMInternalWebViewAccessibilityIdentifier = @"PBMInternalWebViewAccessibilityIdentifier";
typedef BOOL(^PBMIsVisibleViewBlock)(UIView *, UIView *);

static NSString * const KeyPathOutputVolume = @"outputVolume";

#pragma mark - Private Extension

@interface PBMWebView ()

// private webview which renders the ad
@property (nonatomic, strong) WKWebView *internalWebView;
@property (nonatomic, strong) WKUserContentController *wkUserContentController;

// redirect protection
@property (nonatomic, strong) NSDate *lastTapTimestamp;

@property (nonatomic, assign) BOOL isVolumeObserverSetup;

// viewability polling
@property (nonatomic, strong, nullable) PBMCreativeViewabilityTracker *viewabilityTracker;

// the last frame sent to an ad via onSizeChange
@property (nonatomic, assign) CGRect mraidLastSentFrame;

@property (nonatomic, strong, nullable) PrebidJSLibraryManager *libraryManager;

// Need to avoid warnings
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

// polling
@property (nonatomic, assign) BOOL isPollingForDocumentReady;


@property (nonatomic, strong, readonly, nonnull) Targeting *targeting;

@end

#pragma mark - Implementation

@implementation PBMWebView

#pragma mark - Initialization
 
- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame creativeModel:nil targeting:Targeting.shared];
    return self;
}
 
- (nonnull instancetype)initWithFrame:(CGRect)frame
                        creativeModel:(PBMCreativeModel *)creativeModel
                            targeting:(Targeting *)targeting
{
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }
    self.accessibilityIdentifier = PBMAccesibility.WebViewLabel;
    WKUserContentController * const wkUserContentController = [[WKUserContentController alloc] init];
    self.wkUserContentController = wkUserContentController;
    _targeting = targeting;
    _libraryManager = PrebidJSLibraryManager.shared;
    _lastTapTimestamp = NSDate.distantPast;
    _viewable = NO;
    _isMRAID = NO;
    _rotationEnabled = YES;
    _state = PBMWebViewStateLoading;
    self.mraidState = PBMMRAIDStateNotEnabled;
    _mraidLastSentFrame = CGRectZero;
    _bundle = [PBMFunctions bundleForSDK];
    _isVolumeObserverSetup = NO;
    
    //Setup MRAID-required properties
    //see section '8.4 Video' (page 68) of MRAID 3.0 specification
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.allowsInlineMediaPlayback = YES;
    if (@available(iOS 10.0, *)) {
        configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    }
    
    //Add a Script Message Handler for "log"
    [wkUserContentController addScriptMessageHandler:[[PBMWKScriptMessageHandlerLeakAvoider alloc] initWithDelegate:self] name:@"log"];
    
    //Add a meta tag to lock zoom to 100%
    //Add a style tag to keep margin at 0px.
    NSString *js =  @"var headTag = document.getElementsByTagName('head')[0];"
                    @"var metaTag = document.createElement('meta');"
                    @"metaTag.name = 'viewport';"
                    @"metaTag.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';"
                    @"headTag.appendChild(metaTag);"
                    @"var style = document.createElement('style');"
                    @"style.innerHTML = 'body {margin:0px; padding:0px;}';"
                    @"headTag.appendChild(style);";
    
    //Run JS
    WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    [wkUserContentController addUserScript:script];
    
    //Create the WKWebView
    configuration.userContentController = wkUserContentController;
    WKWebView * const internalWebView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    [internalWebView setOpaque:NO];
    
    _internalWebView = internalWebView;
    
    [internalWebView.scrollView setScrollEnabled:NO];
    internalWebView.scrollView.bounces = NO;
    internalWebView.accessibilityIdentifier = PBMInternalWebViewAccessibilityIdentifier;
    
    [self addSubview:self.internalWebView];
    
    [internalWebView PBMAddFillSuperviewConstraints];
    internalWebView.navigationDelegate = self;
    internalWebView.UIDelegate = self;
    
    [self setupTapRecognizer];

    //Note: this observer is here and not in initNewWebView because it observes an application-level change, not a webview-level change.
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(observer_UIApplicationDidChangeStatusBarOrientationNotification)
                                               name:UIApplicationDidChangeStatusBarFrameNotification
                                             object:nil];
    
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [super initWithCoder:aDecoder];
}

- (void)dealloc {
    if (self.isVolumeObserverSetup) {
        [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:KeyPathOutputVolume];
    }
}

#pragma mark - API

/**
 Loads an HTML string with an optional base URL.
 
 If the supplied HTML string or the internal `WKWebView`'s state is invalid, will fail to load.
 
 This function is used by PBMHTMLCreative to load html ads for both .auid and .html AdUnitIdentifierTypes
 
 - parameters:
 - html: "Valid" HTML string including at least opening and closing <html> tags.
 - baseURL: Optional base URL to load HTML with.
 */
- (void)loadHTML:(nonnull NSString *)html baseURL:(nullable NSURL *)baseURL injectMraidJs:(BOOL)injectMraidJs {
    [self loadHTML:html baseURL:baseURL injectMraidJs:injectMraidJs currentThread:NSThread.currentThread];
}

- (void)loadHTML:(nonnull NSString *)html
         baseURL:(nullable NSURL *)baseURL
         injectMraidJs:(BOOL)injectMraidJs
   currentThread:(id<PBMNSThreadProtocol>)currentThread {
    if (!html) {
        PBMLogError(@"Input HTML is nil");
        return;
    }
    
    if (!currentThread.isMainThread) {
        PBMLogError(@"Attempting to loadHTML on background thread");
    }
    
    @weakify(self);
    [self loadContentWithMRAID:injectMraidJs forExpandContent:NO contentLoader:^{
        @strongify(self);
        if (!self) { return; }
        
        PBMLogInfo(@"loadHTMLString");
        self.state = PBMWebViewStateLoading;
        
        [self.internalWebView loadHTMLString:html baseURL:nil];
    } onError:^(NSError * _Nullable error) {
        PBMLogError(@"%@", error.localizedDescription);
    }];
}

/**
 Loads HTML from a URL.
 This function is used by PBMHTMLCreative to support MRAID.expand
 
 - parameters:
 - url: The URL to be loaded
 */
- (void)expand:(nonnull NSURL *)url {
    [self expand:url currentThread:NSThread.currentThread];
}

- (void)expand:(nonnull NSURL *)url currentThread:(id<PBMNSThreadProtocol>)currentThread {
    if (!url) {
        PBMLogError(@"Could not expand with nil url");
        return;
    }
    
    if (!currentThread.isMainThread) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self expand:url];
        });
        
        return;
    }
    
    @weakify(self);
    [self loadContentWithMRAID:YES forExpandContent:YES contentLoader:^{
        @strongify(self);
        if (!self) { return; }
        
        self.state = PBMWebViewStateLoading;
        [self.internalWebView loadRequest:[NSURLRequest requestWithURL:url]];
    } onError:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (!self) { return; }
            
            [self.delegate webView:self failedToLoadWithError:error];
        });
    }];
}

+ (BOOL)isVisibleView:(UIView *)view {
    if (!view) {
        return NO;
    }
    
    return [view pbmIsVisibleInView:view.superview] && view.window != nil;
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    [webView loadRequest:navigationAction.request];
    return nil;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                                                     decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    //If there's no URL, bail
    NSURL *url = navigationAction.request.URL;
    if (!url) {
        PBMLogWarn(@"No URL found on WKWebView navigation");
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    //Identify and process MRAID links
    if ([PBMMRAIDController isMRAIDLink:url.absoluteString]) {
        self.isMRAID = YES;
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (!self) { return; }
            [self.delegate webView:self receivedMRAIDLink:url];
        });
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // Identify and process rewarded events
    if (self.rewardedAdURL) {
        if ([url.absoluteString isEqualToString:self.rewardedAdURL]) {
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                if (!self) { return; }
                [self.delegate webView:self receivedRewardedEventLink:url];
            });
            
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }

    //If this is the first URL, allow it.
    if (self.state == PBMWebViewStateLoading) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    //Bail if the state is uninitialized, unloaded, or still loading.
    if (self.state != PBMWebViewStateLoaded) {
        PBMLogWarn(@"Unexpected state [%@] found on navigation to url: %@", [PBMWebView webViewStateDescription:self.state], url);
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    //Prevent malicious auto-clicking
    if ([self wasRecentlyTapped]) {
        //Open clickthrough
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (!self) { return; }
            [self.delegate webView:self receivedClickthroughLink:url];
        });
    } else {
        PBMLogWarn(@"User has not recently tapped. Auto-click suppression is preventing navigation to: %@", url);
    }
    
    decisionHandler(WKNavigationActionPolicyCancel);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    PBMLogWhereAmI();
    [self pollForDocumentReadyState];
}

- (void)pollForDocumentReadyState {
    if (self.isPollingForDocumentReady || self.state == PBMWebViewStateLoaded) {
        return;
    }
    self.isPollingForDocumentReady = YES;
    [self checkDocumentReadyState];
}

- (void)checkDocumentReadyState {
    @weakify(self);
    WKUserScript *script = [[WKUserScript alloc] initWithSource:@"document.readyState" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self.internalWebView.configuration.userContentController addUserScript:script];
    [self.internalWebView evaluateJavaScript:@"document.readyState" completionHandler:^(NSString * _Nullable readyState, NSError * _Nullable error) {
        // This callback always runs on main thread
        @strongify(self);
        
        if (self == nil) {
            return;
        }
        
        if ([readyState isEqualToString:@"complete"]) {
            self.state = PBMWebViewStateLoaded;
            self.isPollingForDocumentReady = NO;
            [self.delegate webViewReadyToDisplay:self];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                @strongify(self);
                
                if (!self) { return; }
                
                [self checkDocumentReadyState];
            });
        }
    }];
}

static PBMError *extracted(NSString *errorMessage) {
    return [PBMError errorWithMessage:PBMErrorTypeInternalError type:errorMessage];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    PBMLogWhereAmI();
    self.state = PBMWebViewStateUnloaded;
    NSString *errorMessage = [NSString stringWithFormat:@"WebView failed to load. Error description: %@, domain: %@, code: %li, userInfo: %@", error.localizedDescription, error.domain, (long)error.code, error.userInfo];
    PBMError *prebidError = extracted(errorMessage);
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (!self) { return; }
        
        [self.delegate webView:self failedToLoadWithError:prebidError];
    });
}

#ifdef DEBUG
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    [PBMFunctions checkCertificateChallenge:challenge completionHandler:completionHandler];
}
#endif

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    PBMLogInfo(@"JS: %@", (NSString *)message.body ?: @"");
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - OutputVolume listener

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([keyPath isEqualToString:KeyPathOutputVolume]) {
        [self MRAID_onAudioVolumeChange:change[NSKeyValueChangeNewKey]];
    }
}

- (void)audioSessionWasInterrupted:(NSNotification *)notification {
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:@(AVAudioSessionInterruptionTypeBegan)]) {
            [self MRAID_onAudioVolumeChange:nil];
        } else {
            NSNumber *volume = @([AVAudioSession sharedInstance].outputVolume);
            [self MRAID_onAudioVolumeChange:volume];
        }
    }
}

#pragma mark - Rotation

//If the publisher app changes orientations, reset the content offset back to 0,0.
//This fixes an issue where upon rotation the ad content may shift slightly.
- (void)observer_UIApplicationDidChangeStatusBarOrientationNotification {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (!self) { return; }
        
        [self onStatusBarOrientationChanged];
    });
}

// update the mraid layout information whenever the frame changes (including on rotation) so the ad can resize itself
- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateMRAIDLayoutInfoWithForceNotification:NO];
}

#pragma mark - MRAID Injection

- (BOOL)injectMRAIDForExpandContent:(BOOL)isForExpandContent error:(NSError **)error {
    NSString *mraidScript = [self.libraryManager getMRAIDLibrary];
    if (!mraidScript) {
        [PBMError createError:error message:@"Could not load mraid.js from library manager" type:PBMErrorTypeInternalError];
        return false;
    }
    
    //Execute mraid.js
    @weakify(self);
    WKUserScript *script = [[WKUserScript alloc] initWithSource:mraidScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self.internalWebView.configuration.userContentController addUserScript:script];
    [self.internalWebView evaluateJavaScript:mraidScript completionHandler:^(id _Nullable jsRet, NSError * _Nullable error) {
        @strongify(self);
        if (!self) { return; }
        
        if (error) {
            PBMLogError(@"Error injecting MRAID script: %@", error);
            return;
        }
        
        [self MRAID_updateSizes];
        
        //When mraid.js finishes loading, change MRAID state to either Ready or Expanded.
        NSString *command = isForExpandContent ?
            [PBMMRAIDJavascriptCommands onReadyExpanded] :
            [PBMMRAIDJavascriptCommands onReady];
        
        WKUserScript *script = [[WKUserScript alloc] initWithSource:command injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self.internalWebView.configuration.userContentController addUserScript:script];
        [self.internalWebView evaluateJavaScript:command completionHandler:^(id _Nullable javaScriptString, NSError * _Nullable error) {
            //When the state has finished changing, update our own MRAID state
            if (error) {
                PBMLogError(@"Error calling %@: %@", command, error.localizedDescription);
                return;
            }

            self.mraidState = isForExpandContent ? PBMMRAIDStateExpanded : PBMMRAIDStateDefault;
        }];
    }];
    
    return YES;
}

- (void)injectMRAIDEnvAndExecute:(nonnull PBMVoidBlock)completionBlock onError:(void (^_Nullable)(NSError * _Nonnull error))onError {
    WKUserScript *script = [[WKUserScript alloc] initWithSource:[self buildMraidEnvObject] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self.internalWebView.configuration.userContentController addUserScript:script];
    [self.internalWebView evaluateJavaScript:[self buildMraidEnvObject] completionHandler:^(id _Nullable jsRet, NSError * _Nullable error) {
        if (error) {
            if (onError) {
                onError(error);
            }
        } else {
            completionBlock();
        }
    }];
}

- (NSString *)buildMraidEnvObject {
    NSMutableString * const s = [[NSMutableString alloc] init];
    __block BOOL firstCalled = NO;
    PBMVoidBlock const nextFeed = ^{
        if (!firstCalled) {
            firstCalled = YES;
        } else {
            [s appendString:@","];
        }
        [s appendString:@"\n  "];
    };
    [s appendString:@"window.MRAID_ENV = {"];
    nextFeed(); [s appendString:@"version: '3.0'"];
    nextFeed(); [s appendString:@"sdk: 'prebid-mobile-sdk'"];
    nextFeed(); [s appendFormat:@"sdkVersion: '%@'", [PBMFunctions sdkVersion]];
    nextFeed(); [s appendFormat:@"appId: '%@'", [NSBundle mainBundle].bundleIdentifier];
    nextFeed(); [s appendFormat:@"ifa: '%@'", [ASIdentifierManager.sharedManager advertisingIdentifier].UUIDString];
    nextFeed(); [s appendFormat:@"limitAdTracking: %@", ![ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled ? @"true" : @"false"];
    nextFeed(); [s appendFormat:@"coppa: %@", [self.targeting.coppa isEqualToNumber: @(1)] ? @"true" : @"false"];
    [s appendString:@"}"];
    return s;
}

- (void)loadContentWithMRAID:(BOOL)injectMRAID forExpandContent:(BOOL)forExpandContent contentLoader:(nonnull PBMVoidBlock)contentLoader onError:(void (^_Nullable)(NSError * _Nullable error))onError {
    if (injectMRAID) {
        @weakify(self);
        PBMVoidBlock injectMraidLib = ^{
            @strongify(self);
            if (!self) { return; }
            
            NSError *error = nil;
            if(![self injectMRAIDForExpandContent:forExpandContent error:&error]) {
                if (error && onError) {
                    onError(error);
                }
                return;
            }
            
            contentLoader();
        };
        // > In the case of a 2-part ad, the host only makes the MRAID_ENV object available to the initial ad.
        // > The second part of the 2-part ad must use details the ad received in the first part if the second part needs those details.
        //
        // see '3.1.2 Declaring MRAID Environment Details', p.17-19 of MRAID 3.0 specification
        if (!forExpandContent) {
            [self injectMRAIDEnvAndExecute:^{
                injectMraidLib();
            } onError:^(NSError * _Nonnull error) {
                onError(error);
            }];
        } else {
            injectMraidLib();
        }
    } else {
        contentLoader();
    }
}

#pragma mark - MRAID

- (void)prepareForMRAIDWithRootViewController:(UIViewController*)viewController {
    [self setSupportedMRAIDFeatures];
    
    [self MRAID_updateSizes];
    
    [self MRAID_updateLocation];
    BOOL isLocked = [self isOrientationLockedWithViewController:viewController];
    [self MRAID_updateCurrentAppOrientationIsLocked:isLocked];
    
    [self pollForViewability];
    [self setupVolumeObserver];
}

- (void)MRAID_updateSizes {
    [self MRAID_updateMaxSize];
    [self MRAID_updateScreenSize];
    [self MRAID_updateDefaultPosition:self.frame];
    [self MRAID_updateCurrentPosition:self.frame forceNotification:NO];
}

- (BOOL)isOrientationLockedWithViewController:(UIViewController *)viewController {

    if (viewController == nil) {
        return NO;
    }
    
    UIInterfaceOrientationMask mask = [viewController supportedInterfaceOrientations];
    BOOL isPortraiteSupported = mask & UIInterfaceOrientationMaskPortrait ||
                                mask & UIInterfaceOrientationMaskPortraitUpsideDown;
    BOOL isLandscapeSupported = mask & UIInterfaceOrientationMaskLandscape ||
                                mask & UIInterfaceOrientationMaskLandscapeLeft;
    BOOL isLocked = !isPortraiteSupported || !isLandscapeSupported;
    
    return isLocked;
}

- (void)setupVolumeObserver {
    if (!self.isVolumeObserverSetup) {
        self.isVolumeObserverSetup = YES;
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[AVAudioSession sharedInstance] addObserver:self
                                          forKeyPath:KeyPathOutputVolume
                                             options:NSKeyValueObservingOptionNew
                                             context:nil];
        NSNumber *volume = @([AVAudioSession sharedInstance].outputVolume);
        [self MRAID_onAudioVolumeChange:volume];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                                 selector:@selector(audioSessionWasInterrupted:)
                                                     name:AVAudioSessionInterruptionNotification object:nil];
    }
}

- (void)updateMRAIDLayoutInfoWithForceNotification:(BOOL)forceNotification {
    //PBMLogInfo(@"MRAID_updateLayoutInfo HAS BEEN CALLED");
    [self MRAID_updateCurrentPosition:self.frame forceNotification:forceNotification];
    //self.MRAID_onViewableChange(PBMFunctions.isVisible(self))
}

- (void)changeToMRAIDState:(PBMMRAIDState)state {
    self.mraidState = state;
    [self MRAID_onStateChange:state];
}

#pragma mark - Calling handlers in mraid.js

- (void)MRAID_nativeCallComplete {
    NSString *command = [PBMMRAIDJavascriptCommands nativeCallComplete];
    if (NSThread.isMainThread) {
        WKUserScript *script = [[WKUserScript alloc] initWithSource:command injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self.internalWebView.configuration.userContentController addUserScript:script];
        [self.internalWebView evaluateJavaScript:command completionHandler:^(id _Nullable jsRet, NSError * _Nullable error) {
            if (error) {
                PBMLogError(@"Error of executing command %@", command);
            }
        }];
    } else {
        [self evaluateJavaScript:command];
    }
}

// updates the webview's size in mraid.js
- (void)MRAID_onSizeChange {
    if (CGRectEqualToRect(self.frame, self.mraidLastSentFrame)) {
        return;
    }
    
    self.mraidLastSentFrame = self.frame;
    [self evaluateJavaScript:[PBMMRAIDJavascriptCommands onSizeChange:self.frame.size]];
    
    //these changes were fired by a transition default => expened, default => resize ....
    if (self.viewabilityTracker != nil && self.exposureDelegate != nil && [self.exposureDelegate shouldCheckExposure]) {
        [self.viewabilityTracker checkExposureWithForce:YES];
    }
}

// updates the state of the webview in mraid.js
- (void)MRAID_onStateChange:(PBMMRAIDState)state {
    [self evaluateJavaScript:[PBMMRAIDJavascriptCommands onStateChange:state]];
}

// updates the viewable flag in mraid.js
- (void)MRAID_onExposureChange:(PBMViewExposure *)viewExposure {
    BOOL const newViewable = viewExposure.exposureFactor > 0;
    if (self.isViewable != newViewable) {
        self.viewable = newViewable;
        [self evaluateJavaScript:[PBMMRAIDJavascriptCommands onViewableChange:newViewable]];
    }
    
    [self evaluateJavaScript:[PBMMRAIDJavascriptCommands onExposureChange:viewExposure]];
}

// fires the audioVolumeChange event in mraid.js
- (void)MRAID_onAudioVolumeChange:(NSNumber *)volumeValue {
    NSNumber *volumePercentage = (volumeValue == nil) ? nil : @([volumeValue floatValue] * 100.0);
    [self evaluateJavaScript:[PBMMRAIDJavascriptCommands onAudioVolumeChange:volumePercentage]];
}

#pragma mark - Functions for updating data in mraid.js

// look up what features are avaliable and set them
- (void) setSupportedMRAIDFeatures {
    [self evaluateJavaScript:[PBMMRAIDJavascriptCommands updateSupportedFeatures]];
}

// TODO: call this?
//updates the placement type in mraid.js - can be 'inline' (displayed inline with content) or 'interstitial' as an interstitial overlaid content
- (void)MRAID_updatePlacementType:(PBMMRAIDPlacementType)type {
    [self evaluateJavaScript:[PBMMRAIDJavascriptCommands updatePlacementType:type]];
}

// update the current screen size in mraid.js that can be expanded to, which is the device size minus the status bar
- (void)MRAID_updateScreenSize {
    CGSize screenSize = [PBMFunctions deviceScreenSize];
    [self evaluateJavaScript:[PBMMRAIDJavascriptCommands updateScreenSize:screenSize]];
}

// update the maximum size of the device screen in mraid.js
- (void)MRAID_updateMaxSize {
    CGSize maxSize = [PBMFunctions deviceMaxSize];
    [self evaluateJavaScript:[PBMMRAIDJavascriptCommands updateMaxSize:maxSize]];
}

// This method sets default (starting) position for the webview in mraid.js
- (void)MRAID_updateDefaultPosition:(CGRect)position {
    [self evaluateJavaScript:[PBMMRAIDJavascriptCommands updateDefaultPosition:position]];
}

// sets current position for the webview in mraid.js
- (void)MRAID_updateCurrentPosition:(CGRect)position forceNotification:(BOOL)forceNotification {
    [self evaluateJavaScript:[PBMMRAIDJavascriptCommands updateCurrentPosition:position]];
    [self MRAID_onSizeChange];
}

- (void)MRAID_updateLocation {
    if (Prebid.shared.locationUpdatesEnabled && PBMLocationManager.shared.coordinatesAreValid) {
        PBMLocationManager *locationManager = PBMLocationManager.shared;
        [self evaluateJavaScript:[PBMMRAIDJavascriptCommands updateLocation:locationManager.coordinates
                                                                   accuracy:locationManager.horizontalAccuracy
                                                                    timeStamp:[locationManager.timestamp timeIntervalSince1970]]];
    }
}

- (void)MRAID_updateCurrentAppOrientationIsLocked:(BOOL)locked {
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication.statusBarOrientation);
    [self evaluateJavaScript:[PBMMRAIDJavascriptCommands updateCurrentAppOrientation:(isPortrait ? @"portrait" : @"landscape") locked:locked]];
}

#pragma mark - Functions for getting data out of mraid.js

- (void)MRAID_getExpandProperties:(void(^)(PBMMRAIDExpandProperties *))completionHandler {
    
    NSString *command = [PBMMRAIDJavascriptCommands getExpandProperties];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:command injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self.internalWebView.configuration.userContentController addUserScript:script];
    [self.internalWebView evaluateJavaScript:command completionHandler:^(id _Nullable jsRet, NSError * _Nullable error) {
        if (error) {
            PBMLogError(@"Error getting expand properties: %@", error.localizedDescription);
            completionHandler(nil);
            return;
        }
        
        PBMJsonDictionary *dict = [PBMWebView anyToJSONDict:jsRet];
        if (!dict) {
            completionHandler(nil);
            return;
        }
        
        NSNumber *width = dict[PBMMRAIDParseKeys.WIDTH];
        NSNumber *height = dict[PBMMRAIDParseKeys.HEIGHT];
        if (width && height) {
            PBMMRAIDExpandProperties *mraidExpandProperties = [[PBMMRAIDExpandProperties alloc] initWithWidth:width.integerValue
                                                                                                       height:height.integerValue];
            completionHandler(mraidExpandProperties);
        }
        else {
            completionHandler(nil);
        }
    }];
}

- (void) MRAID_getResizeProperties:(void(^)(PBMMRAIDResizeProperties *))completionHandler {
    if (!completionHandler) {
        PBMLogError(@"The completionHandler is not provided");
        return;
    }
    
    NSString *command = [PBMMRAIDJavascriptCommands getResizeProperties];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:command injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self.internalWebView.configuration.userContentController addUserScript:script];
    [self.internalWebView evaluateJavaScript:command completionHandler:^(id _Nullable jsRet, NSError * _Nullable error) {
        if (error) {
            PBMLogError(@"Error getting Resize Properties: %@", error.localizedDescription);
            completionHandler(nil);
            return;
        }
        
        PBMJsonDictionary *dict = [PBMWebView anyToJSONDict:jsRet];
        if (!dict) {
            completionHandler(nil);
            return;
        }
        
        NSNumber *width = dict[PBMMRAIDParseKeys.WIDTH];
        NSNumber *height = dict[PBMMRAIDParseKeys.HEIGHT];
        NSNumber *offsetX = dict[PBMMRAIDParseKeys.X_OFFSET];
        NSNumber *offsetY = dict[PBMMRAIDParseKeys.Y_OFFSET];
        NSNumber *allowOffscreen = dict[PBMMRAIDParseKeys.ALLOW_OFFSCREEN];
        
        if (width && height && offsetX && offsetY && allowOffscreen) {
            PBMMRAIDResizeProperties *mraidResizeProperties = [[PBMMRAIDResizeProperties alloc] initWithWidth:width.integerValue
                                                                                                       height:height.integerValue
                                                                                                      offsetX:offsetX.integerValue
                                                                                                      offsetY:offsetY.integerValue
                                                                                               allowOffscreen:allowOffscreen.boolValue];
            
            completionHandler(mraidResizeProperties);
        }
        else {
            completionHandler(nil);
        }
    }];
}

// This execute method fire the MRAID 'error' event.
// @param message - description of the type of error
// @param action - name of action that caused error
- (void)MRAID_error:(NSString *)message action:(PBMMRAIDAction)action {
    PBMLogError(@"Action: [%@] generated error with message [%@]", action, message);
    [self evaluateJavaScript:[PBMMRAIDJavascriptCommands onErrorWithMessage:message action: action]];
}
    
//Poll every 200 ms for viewability changes.
//TODO: There is almost certainly a way to do this that is more industry-standard and less processor-intensive.
- (void)pollForViewability {
    @weakify(self);
    self.viewabilityTracker = [[PBMCreativeViewabilityTracker alloc]initWithView:self pollingTimeInterval:0.2f onExposureChange:^(PBMCreativeViewabilityTracker *tracker, PBMViewExposure * _Nonnull viewExposure) {
        @strongify(self);
        if (!self) { return; }

        [self MRAID_onExposureChange:viewExposure];
        if (self.exposureDelegate != nil) {
            [self.exposureDelegate webView:self exposureChange:viewExposure];
        }

    }];
    [self.viewabilityTracker start];
}

#pragma mark - Helper Methods

- (void)evaluateJavaScript:(NSString *)jsCommand {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        // ATTENTION: the invoking of "evaluateJavaScript" not from main thread leads to the crash.
        WKUserScript *script = [[WKUserScript alloc] initWithSource:jsCommand injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self.internalWebView.configuration.userContentController addUserScript:script];
        [self.internalWebView evaluateJavaScript:jsCommand completionHandler:^(id _Nullable jsRes, NSError * _Nullable error) {
            @strongify(self);
            if (!self) { return; }

            if (self.jsEvaluatingCompletion) {
                self.jsEvaluatingCompletion(jsCommand, jsRes, error);
            }
        }];
    });
}

- (void)setupTapRecognizer {
    if (self.tapdownGestureRecognizer) {
        [self.internalWebView removeGestureRecognizer:self.tapdownGestureRecognizer];
    }
    
    self.tapdownGestureRecognizer = [[PBMTouchDownRecognizer alloc] initWithTarget:self action:@selector(recordTapEvent:)];
    [self.tapdownGestureRecognizer setCancelsTouchesInView:YES];
    [self.internalWebView addGestureRecognizer:self.tapdownGestureRecognizer];
    self.tapdownGestureRecognizer.delegate = self;
}

- (void)recordTapEvent:(UITapGestureRecognizer *)tap {
    if (self.tapdownGestureRecognizer != tap) {
        return;
    }
    
    self.lastTapTimestamp = [NSDate new];
}

- (BOOL)wasRecentlyTapped {
    return fabs([self.lastTapTimestamp timeIntervalSinceNow]) < PBMTimeInterval.AD_CLICKED_ALLOWED_INTERVAL;
}

#pragma mark - Orientation changing support

- (void)onStatusBarOrientationChanged {    
    NSString *isPortrait = UIApplication.sharedApplication.statusBarOrientation == UIInterfaceOrientationPortrait ? @"true" : @"false";
    PBMLogInfo(@"Orientation is portrait: %@", isPortrait);
    
    self.internalWebView.scrollView.contentOffset = CGPointMake(0.0, 0.0);
    [self MRAID_updateMaxSize];
    [self updateMRAIDLayoutInfoWithForceNotification:NO];
    
    BOOL isLocked = [self isOrientationLockedWithViewController:[self.delegate viewControllerForPresentingModals]];
    
    [self MRAID_updateCurrentAppOrientationIsLocked:isLocked];
}

#pragma mark - Open Measurement

- (void)addFriendlyObstructionsToMeasurementSession:(PBMOpenMeasurementSession *)session {
}

#pragma mark - Utilities


+ (NSString *)webViewStateDescription:(PBMWebViewState)state {
    switch (state) {
        case PBMWebViewStateUnloaded        : return @"unloaded";
        case PBMWebViewStateLoading         : return @"loading";
        case PBMWebViewStateLoaded          : return @"loaded";
    }
}

+ (PBMJsonDictionary *)anyToJSONDict:(id)str {
    if (![str isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString *jsonString = (NSString *)str;

    // convert string to data so it can be serialized to json object
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    if (!data) {
        return nil;
    }
    
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![jsonObj isKindOfClass:[PBMJsonDictionary class]]) {
        return nil;
    }

    return (PBMJsonDictionary *)jsonObj;
}

@end
