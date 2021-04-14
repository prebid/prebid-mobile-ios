//
//  OXMWebView.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

@import AVFoundation;
@import AdSupport;

#import <JavaScriptCore/JavaScriptCore.h>

#import "OXMAbstractCreative.h"
#import "OXMAdConfiguration.h"
#import "OXMCreativeModel.h"
#import "OXMError.h"
#import "OXMFunctions+Private.h"
#import "OXMInterstitialDisplayProperties.h"
#import "OXMJSLibraryManager.h"
#import "OXMLegalButtonDecorator.h"
#import "OXMLocationManager.h"
#import "OXMLog.h"
#import "OXMMRAIDController.h"
#import "OXMMRAIDJavascriptCommands.h"
#import "OXMMacros.h"
#import "OXMNSThreadProtocol.h"
#import "OXMOpenMeasurementSession.h"
#import "OXMORTB.h"
#import "OXASDKConfiguration.h"
#import "OXMTouchDownRecognizer.h"
#import "OXMViewExposure.h"
#import "OXMCreativeViewabilityTracker.h"
#import "OXATargeting.h"
#import "OXAAgeUtils.h"
#import "OXMWKScriptMessageHandlerLeakAvoider.h"
#import "UIView+OxmExtensions.h"
#import "OXMWebView+oxmTestExtension.h"

#import "OXMWebView.h"

#import "OXMAdViewManagerDelegate.h"

#pragma mark - Constants

static NSString * const OXMInternalWebViewAccessibilityIdentifier = @"OXMInternalWebViewAccessibilityIdentifier";
typedef BOOL(^OXMIsVisibleViewBlock)(UIView *, UIView *);

static NSString * const KeyPathOutputVolume = @"outputVolume";

#pragma mark - Private Extension

@interface OXMWebView ()

// private webview which renders the ad
@property (nonatomic, strong) WKWebView *internalWebView;
@property (nonatomic, strong) WKUserContentController *wkUserContentController;

// redirect protection
@property (nonatomic, strong) NSDate *lastTapTimestamp;

@property (nonatomic, assign) BOOL isVolumeObserverSetup;

@property (nonatomic, assign) OXMPosition originLegalButtonPosition;

// viewability polling
@property (nonatomic, strong, nullable) OXMCreativeViewabilityTracker *viewabilityTracker;

// the last frame sent to an ad via onSizeChange
@property (nonatomic, assign) CGRect mraidLastSentFrame;

// Need to avoid warnings
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

// polling
@property (nonatomic, assign) BOOL isPollingForDocumentReady;


@property (nonatomic, strong, readonly, nonnull) OXATargeting *targeting;

@end

#pragma mark - Implementation

@implementation OXMWebView

#pragma mark - Initialization
 
- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame creativeModel:nil targeting:[OXATargeting shared]];
    return self;
}
 
- (nonnull instancetype)initWithFrame:(CGRect)frame
                        creativeModel:(OXMCreativeModel *)creativeModel
                            targeting:(OXATargeting *)targeting
{
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }
    self.accessibilityIdentifier = OXMAccesibility.WebViewLabel;
    WKUserContentController * const wkUserContentController = [[WKUserContentController alloc] init];
    self.wkUserContentController = wkUserContentController;
    _targeting = targeting;
    _lastTapTimestamp = NSDate.distantPast;
    _viewable = NO;
    _isMRAID = NO;
    _rotationEnabled = YES;
    _state = OXMWebViewStateLoading;
    self.mraidState = OXMMRAIDStateNotEnabled;
    _mraidLastSentFrame = CGRectZero;
    _bundle = [OXMFunctions bundleForSDK];
    _originLegalButtonPosition = OXMPositionUndefined;
    _isVolumeObserverSetup = NO;
    
    //Setup MRAID-required properties
    //see section '8.4 Video' (page 68) of MRAID 3.0 specification
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    configuration.allowsInlineMediaPlayback = YES;
    if (@available(iOS 10.0, *)) {
        configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    }
    
    //Add a Script Message Handler for "log"
    [wkUserContentController addScriptMessageHandler:[[OXMWKScriptMessageHandlerLeakAvoider alloc] initWithDelegate:self] name:@"log"];
    
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
    WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [wkUserContentController addUserScript:script];
    
    //Create the WKWebView
    configuration.userContentController = wkUserContentController;
    WKWebView * const internalWebView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    _internalWebView = internalWebView;
    
    [internalWebView.scrollView setScrollEnabled:NO];
    internalWebView.scrollView.bounces = NO;
    internalWebView.accessibilityIdentifier = OXMInternalWebViewAccessibilityIdentifier;
    
    [self addSubview:self.internalWebView];
    
    [internalWebView OXMAddFillSuperviewConstraints];
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
 
 This function is used by OXMHTMLCreative to load html ads for both .auid and .html AdUnitIdentifierTypes
 
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
   currentThread:(id<OXMNSThreadProtocol>)currentThread {
    if (!html) {
        OXMLogError(@"Input HTML is nil");
        return;
    }
    
    if (!currentThread.isMainThread) {
        OXMLogError(@"Attempting to loadHTML on background thread");
    }
    
    @weakify(self);
    [self loadContentWithMRAID:injectMraidJs forExpandContent:NO contentLoader:^{
         @strongify(self);
         OXMLogInfo(@"loadHTMLString");
         self.state = OXMWebViewStateLoading;
        
         [self.internalWebView loadHTMLString:html baseURL:nil];
         [self updateLegalButton];
    } onError:^(NSError * _Nullable error) {
        OXMLogError(@"%@", error.localizedDescription);
    }];
}

/**
 Loads HTML from a URL.
 This function is used by OXMHTMLCreative to support MRAID.expand
 
 - parameters:
 - url: The URL to be loaded
 */
- (void)expand:(nonnull NSURL *)url {
    [self expand:url currentThread:NSThread.currentThread];
}

- (void)expand:(nonnull NSURL *)url currentThread:(id<OXMNSThreadProtocol>)currentThread {
    if (!url) {
        OXMLogError(@"Could not expand with nil url");
        return;
    }
    
    if (!currentThread.isMainThread) {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self expand:url currentThread:currentThread];
        });
        
        return;
    }
    
    @weakify(self);
    [self loadContentWithMRAID:YES forExpandContent:YES contentLoader:^{
        @strongify(self);
        self.state = OXMWebViewStateLoading;
        [self.internalWebView loadRequest:[NSURLRequest requestWithURL:url]];
    } onError:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.delegate webView:self failedToLoadWithError:error];
        });
    }];
}

+ (BOOL)isVisibleView:(UIView *)view {
    if (!view) {
        return NO;
    }
    
    return [view oxmIsVisibleInView:view.superview] && view.window != nil;
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    [webView loadRequest:navigationAction.request];
    return nil;
}

#pragma mark - WKNavigationDelegate

- (void) webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    //If there's no URL, bail
    NSURL *url = navigationAction.request.URL;
    if (!url) {
        OXMLogWarn(@"No URL found on WKWebView navigation");
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    //Identify and process MRAID links
    if ([OXMMRAIDController isMRAIDLink:url.absoluteString]) {
        self.isMRAID = YES;
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.delegate webView:self receivedMRAIDLink:url];
        });
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    //If this is the first URL, allow it.
    if (self.state == OXMWebViewStateLoading) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    //Bail if the state is uninitialized, unloaded, or still loading.
    if (self.state != OXMWebViewStateLoaded) {
        OXMLogWarn(@"Unexpected state [%@] found on navigation to url: %@", [OXMWebView webViewStateDescription:self.state], url);
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    //Prevent malicious auto-clicking
    if ([self wasRecentlyTapped]) {
        //Open clickthrough
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.delegate webView:self receivedClickthroughLink:url];
        });
    } else {
        OXMLogWarn(@"User has not recently tapped. Auto-click suppression is preventing navigation to: %@", url);
    }
    
    decisionHandler(WKNavigationActionPolicyCancel);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    OXMLogWhereAmI();
    [self pollForDocumentReadyState];
}

- (void)pollForDocumentReadyState {
    if (self.isPollingForDocumentReady || self.state == OXMWebViewStateLoaded) {
        return;
    }
    self.isPollingForDocumentReady = YES;
    [self checkDocumentReadyState];
}

- (void)checkDocumentReadyState {
    @weakify(self);
    [self.internalWebView evaluateJavaScript:@"document.readyState" completionHandler:^(NSString * _Nullable readyState, NSError * _Nullable error) {
        // This callback always runs on main thread
        
        @strongify(self);
        if (self == nil) {
            return;
        }
        if ([readyState isEqualToString:@"complete"]) {
            self.state = OXMWebViewStateLoaded;
            self.isPollingForDocumentReady = NO;
            [self.delegate webViewReadyToDisplay:self];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                @strongify(self);
                [self checkDocumentReadyState];
            });
        }
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    OXMLogWhereAmI();
    self.state = OXMWebViewStateUnloaded;
    NSString *errorMessage = [NSString stringWithFormat:@"WebView failed to load. Error description: %@, domain: %@, code: %li, userInfo: %@", error.localizedDescription, error.domain, (long)error.code, error.userInfo];
    OXMError *oxmError = [OXMError errorWithMessage:OXAErrorTypeInternalError type:errorMessage];
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.delegate webView:self failedToLoadWithError:oxmError];
    });
}

#ifdef DEBUG
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    [OXMFunctions checkCertificateChallenge:challenge completionHandler:completionHandler];
}
#endif

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    OXMLogInfo(@"JS: %@", (NSString *)message.body ?: @"");
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
    [OXMJSLibraryManager sharedManager].bundle = self.bundle;
    NSString *mraidScript = [[OXMJSLibraryManager sharedManager] getMRAIDLibrary];
    if (!mraidScript) {
        [OXMError createError:error message:@"Could not load mraid.js from library manager" type:OXAErrorTypeInternalError];
        return false;
    }
    
    //Execute mraid.js
    @weakify(self);
    [self.internalWebView evaluateJavaScript:mraidScript completionHandler:^(id _Nullable jsRet, NSError * _Nullable error) {
        @strongify(self);
        if (error) {
            OXMLogError(@"Error injecting MRAID script: %@", error);
            return;
        }
        
        [self MRAID_updateSizes];
        
        //When mraid.js finishes loading, change MRAID state to either Ready or Expanded.
        NSString *command = isForExpandContent ?
            [OXMMRAIDJavascriptCommands onReadyExpanded] :
            [OXMMRAIDJavascriptCommands onReady];
        
        [self.internalWebView evaluateJavaScript:command completionHandler:^(id _Nullable javaScriptString, NSError * _Nullable error) {
            //When the state has finished changing, update our own MRAID state
            if (error) {
                OXMLogError(@"Error calling %@: %@", command, error.localizedDescription);
                return;
            }

            self.mraidState = isForExpandContent ? OXMMRAIDStateExpanded : OXMMRAIDStateDefault;
        }];
    }];
    
    return YES;
}

- (void)injectMRAIDEnvAndExecute:(nonnull OXMVoidBlock)completionBlock onError:(void (^_Nullable)(NSError * _Nonnull error))onError {
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
    OXMVoidBlock const nextFeed = ^{
        if (!firstCalled) {
            firstCalled = YES;
        } else {
            [s appendString:@","];
        }
        [s appendString:@"\n  "];
    };
    [s appendString:@"window.MRAID_ENV = {"];
    nextFeed(); [s appendString:@"version: '3.0'"];
    nextFeed(); [s appendString:@"sdk: 'openx-ios-sdk'"];
    nextFeed(); [s appendFormat:@"sdkVersion: '%@'", [OXMFunctions sdkVersion]];
    nextFeed(); [s appendFormat:@"appId: '%@'", [NSBundle mainBundle].bundleIdentifier];
    nextFeed(); [s appendFormat:@"ifa: '%@'", [ASIdentifierManager.sharedManager advertisingIdentifier].UUIDString];
    nextFeed(); [s appendFormat:@"limitAdTracking: %@", ![ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled ? @"true" : @"false"];
    nextFeed(); [s appendFormat:@"coppa: %@", [self.targeting.coppa isEqualToNumber: @(1)] ? @"true" : @"false"];
    [s appendString:@"}"];
    return s;
}

- (void)loadContentWithMRAID:(BOOL)injectMRAID forExpandContent:(BOOL)forExpandContent contentLoader:(nonnull OXMVoidBlock)contentLoader onError:(void (^_Nullable)(NSError * _Nullable error))onError {
    if (injectMRAID) {
        @weakify(self);
        OXMVoidBlock injectMraidLib = ^{
            @strongify(self);
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
    //OXMLog.log("MRAID_updateLayoutInfo HAS BEEN CALLED")
    [self MRAID_updateCurrentPosition:self.frame forceNotification:forceNotification];
    //self.MRAID_onViewableChange(OXMFunctions.isVisible(self))
}

- (void)changeToMRAIDState:(OXMMRAIDState)state {
    self.mraidState = state;
    [self MRAID_onStateChange:state];
}

#pragma mark - Calling handlers in mraid.js

- (void)MRAID_nativeCallComplete {
    NSString *command = [OXMMRAIDJavascriptCommands nativeCallComplete];
    if (NSThread.isMainThread) {
        [self.internalWebView evaluateJavaScript:command completionHandler:^(id _Nullable jsRet, NSError * _Nullable error) {
            if (error) {
                OXMLogError(@"Error of executing command %@", command);
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
    [self evaluateJavaScript:[OXMMRAIDJavascriptCommands onSizeChange:self.frame.size]];
    
    //these changes were fired by a transition default => expened, default => resize ....
    if (self.viewabilityTracker != nil && self.exposureDelegate != nil && [self.exposureDelegate shouldCheckExposure]) {
        [self.viewabilityTracker checkExposureWithForce:YES];
    }
}

// updates the state of the webview in mraid.js
- (void)MRAID_onStateChange:(OXMMRAIDState)state {
    [self evaluateJavaScript:[OXMMRAIDJavascriptCommands onStateChange:state]];
    [self updateLegalButton];
}

// updates the viewable flag in mraid.js
- (void)MRAID_onExposureChange:(OXMViewExposure *)viewExposure {
    BOOL const newViewable = viewExposure.exposureFactor > 0;
    if (self.isViewable != newViewable) {
        self.viewable = newViewable;
        [self evaluateJavaScript:[OXMMRAIDJavascriptCommands onViewableChange:newViewable]];
    }
    
    [self evaluateJavaScript:[OXMMRAIDJavascriptCommands onExposureChange:viewExposure]];
}

// fires the audioVolumeChange event in mraid.js
- (void)MRAID_onAudioVolumeChange:(NSNumber *)volumeValue {
    NSNumber *volumePercentage = (volumeValue == nil) ? nil : @([volumeValue floatValue] * 100.0);
    [self evaluateJavaScript:[OXMMRAIDJavascriptCommands onAudioVolumeChange:volumePercentage]];
}

#pragma mark - Functions for updating data in mraid.js

// look up what features are avaliable and set them
- (void) setSupportedMRAIDFeatures {
    [self evaluateJavaScript:[OXMMRAIDJavascriptCommands updateSupportedFeatures]];
}

// TODO: call this?
//updates the placement type in mraid.js - can be 'inline' (displayed inline with content) or 'interstitial' as an interstitial overlaid content
- (void)MRAID_updatePlacementType:(OXMMRAIDPlacementType)type {
    [self evaluateJavaScript:[OXMMRAIDJavascriptCommands updatePlacementType:type]];
}

// update the current screen size in mraid.js that can be expanded to, which is the device size minus the status bar
- (void)MRAID_updateScreenSize {
    CGSize screenSize = [OXMFunctions deviceScreenSize];
    [self evaluateJavaScript:[OXMMRAIDJavascriptCommands updateScreenSize:screenSize]];
}

// update the maximum size of the device screen in mraid.js
- (void)MRAID_updateMaxSize {
    CGSize maxSize = [OXMFunctions deviceMaxSize];
    [self evaluateJavaScript:[OXMMRAIDJavascriptCommands updateMaxSize:maxSize]];
}

// This method sets default (starting) position for the webview in mraid.js
- (void)MRAID_updateDefaultPosition:(CGRect)position {
    [self evaluateJavaScript:[OXMMRAIDJavascriptCommands updateDefaultPosition:position]];
}

// sets current position for the webview in mraid.js
- (void)MRAID_updateCurrentPosition:(CGRect)position forceNotification:(BOOL)forceNotification {
    [self evaluateJavaScript:[OXMMRAIDJavascriptCommands updateCurrentPosition:position]];
    [self MRAID_onSizeChange];
}

- (void)MRAID_updateLocation {
    if (OXASDKConfiguration.singleton.locationUpdatesEnabled && OXMLocationManager.singleton.coordinatesAreValid) {
        OXMLocationManager *locationManager = OXMLocationManager.singleton;
        [self evaluateJavaScript:[OXMMRAIDJavascriptCommands updateLocation:locationManager.coordinates
                                                                   accuracy:locationManager.horizontalAccuracy
                                                                    timeStamp:[locationManager.timestamp timeIntervalSince1970]]];
    }
}

- (void)MRAID_updateCurrentAppOrientationIsLocked:(BOOL)locked {
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication.statusBarOrientation);
    [self evaluateJavaScript:[OXMMRAIDJavascriptCommands updateCurrentAppOrientation:(isPortrait ? @"portrait" : @"landscape") locked:locked]];
}

#pragma mark - Functions for getting data out of mraid.js

- (void)MRAID_getExpandProperties:(void(^)(OXMMRAIDExpandProperties *))completionHandler {
    
    NSString *command = [OXMMRAIDJavascriptCommands getExpandProperties];
    [self.internalWebView evaluateJavaScript:command completionHandler:^(id _Nullable jsRet, NSError * _Nullable error) {
        if (error) {
            OXMLogError(@"Error getting expand properties: %@", error.localizedDescription);
            completionHandler(nil);
            return;
        }
        
        OXMJsonDictionary *dict = [OXMWebView anyToJSONDict:jsRet];
        if (!dict) {
            completionHandler(nil);
            return;
        }
        
        NSNumber *width = dict[OXMMRAIDParseKeys.WIDTH];
        NSNumber *height = dict[OXMMRAIDParseKeys.HEIGHT];
        if (width && height) {
            OXMMRAIDExpandProperties *mraidExpandProperties = [[OXMMRAIDExpandProperties alloc] initWithWidth:width.integerValue
                                                                                                       height:height.integerValue];
            completionHandler(mraidExpandProperties);
        }
        else {
            completionHandler(nil);
        }
    }];
}

- (void) MRAID_getResizeProperties:(void(^)(OXMMRAIDResizeProperties *))completionHandler {
    if (!completionHandler) {
        OXMLogError(@"The completionHandler is not provided");
        return;
    }
    
    NSString *command = [OXMMRAIDJavascriptCommands getResizeProperties];
    [self.internalWebView evaluateJavaScript:command completionHandler:^(id _Nullable jsRet, NSError * _Nullable error) {
        if (error) {
            OXMLogError(@"Error getting Resize Properties: %@", error.localizedDescription);
            completionHandler(nil);
            return;
        }
        
        OXMJsonDictionary *dict = [OXMWebView anyToJSONDict:jsRet];
        if (!dict) {
            completionHandler(nil);
            return;
        }
        
        NSNumber *width = dict[OXMMRAIDParseKeys.WIDTH];
        NSNumber *height = dict[OXMMRAIDParseKeys.HEIGHT];
        NSNumber *offsetX = dict[OXMMRAIDParseKeys.X_OFFSET];
        NSNumber *offsetY = dict[OXMMRAIDParseKeys.Y_OFFSET];
        NSNumber *allowOffscreen = dict[OXMMRAIDParseKeys.ALLOW_OFFSCREEN];
        
        if (width && height && offsetX && offsetY && allowOffscreen) {
            OXMMRAIDResizeProperties *mraidResizeProperties = [[OXMMRAIDResizeProperties alloc] initWithWidth:width.integerValue
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
- (void)MRAID_error:(NSString *)message action:(OXMMRAIDAction)action {
    OXMLogError(@"Action: [%@] generated error with message [%@]", action, message);
    [self evaluateJavaScript:[OXMMRAIDJavascriptCommands onErrorWithMessage:message action: action]];
}
    
//Poll every 200 ms for viewability changes.
//TODO: There is almost certainly a way to do this that is more industry-standard and less processor-intensive.
- (void)pollForViewability {
    @weakify(self);
    self.viewabilityTracker = [[OXMCreativeViewabilityTracker alloc]initWithView:self pollingTimeInterval:0.2f onExposureChange:^(OXMCreativeViewabilityTracker *tracker, OXMViewExposure * _Nonnull viewExposure) {
        @strongify(self);
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
        [self.internalWebView evaluateJavaScript:jsCommand completionHandler:^(id _Nullable jsRes, NSError * _Nullable error) {
            @strongify(self);
            
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
    
    self.tapdownGestureRecognizer = [[OXMTouchDownRecognizer alloc] initWithTarget:self action:@selector(recordTapEvent:)];
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
    return fabs([self.lastTapTimestamp timeIntervalSinceNow]) < OXMTimeInterval.AD_CLICKED_ALLOWED_INTERVAL;
}

- (void)updateLegalButtonForCreative:(OXMAbstractCreative *)creative {

    if (creative.creativeModel.adConfiguration.presentAsInterstitial) {
        [self.legalButtonDecorator removeButtonFromSuperview];
        return;
    }
    
    [self updateLegalButton];
}

- (void)updateLegalButton {
    // Currently, in the case of HTML ad, we must place the legal button to the superview to show it properly in interstitial mode.
    // For the banner ad, the button will be placed in OXMBannerView.
    // For Interstitial in the intermediate view that fills the modal controller.
    // TODO: Make the structure of Banner, HTML Interstitial and Video Interstitial ads more similar.  It will give the ability to manage our buttons on the same level.
    
    [self.legalButtonDecorator removeButtonFromSuperview];
    
    if (self.mraidState == OXMMRAIDStateExpanded || self.mraidState == OXMMRAIDStateResized) {
        self.originLegalButtonPosition = self.legalButtonDecorator.buttonPosition;
        self.legalButtonDecorator.buttonPosition = OXMPositionBottomRight;
    } else if (self.mraidState == OXMMRAIDStateDefault && self.originLegalButtonPosition != OXMPositionUndefined) {
        self.legalButtonDecorator.buttonPosition = self.originLegalButtonPosition;
    }
    
    [self.legalButtonDecorator addButtonToView:self displayView:self];
    
    [self.legalButtonDecorator bringButtonToFront];
}

#pragma mark - Orientation changing support

- (void)onStatusBarOrientationChanged {    
    NSString *isPortrait = UIApplication.sharedApplication.statusBarOrientation == UIInterfaceOrientationPortrait ? @"true" : @"false";
    OXMLogInfo(@"Orientation is portrait: %@", isPortrait);
    
    self.internalWebView.scrollView.contentOffset = CGPointMake(0.0, 0.0);
    [self MRAID_updateMaxSize];
    [self updateMRAIDLayoutInfoWithForceNotification:NO];
    
    BOOL isLocked = [self isOrientationLockedWithViewController:[self.delegate viewControllerForPresentingModals]];
    
    [self MRAID_updateCurrentAppOrientationIsLocked:isLocked];
}

#pragma mark - Open Measurement

- (void)addFriendlyObstructionsToMeasurementSession:(OXMOpenMeasurementSession *)session {
    [session addFriendlyObstruction:self.legalButtonDecorator.button purpose:OXMOpenMeasurementFriendlyObstructionLegalButtonDecorator];
}

#pragma mark - Utilities


+ (NSString *)webViewStateDescription:(OXMWebViewState)state {
    switch (state) {
        case OXMWebViewStateUnloaded        : return @"unloaded";
        case OXMWebViewStateLoading         : return @"loading";
        case OXMWebViewStateLoaded          : return @"loaded";
    }
}

+ (OXMJsonDictionary *)anyToJSONDict:(id)str {
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
    if (![jsonObj isKindOfClass:[OXMJsonDictionary class]]) {
        return nil;
    }

    return (OXMJsonDictionary *)jsonObj;
}

@end
