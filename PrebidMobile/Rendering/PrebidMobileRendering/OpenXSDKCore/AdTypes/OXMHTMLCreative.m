//
//  OXMHTMLCreative.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

//MRAID spec URLs:
//https://www.iab.com/wp-content/uploads/2015/08/IAB_MRAID_v2_FINAL.pdf
//https://www.iab.com/wp-content/uploads/2017/07/MRAID_3.0_FINAL.pdf

#import "OXMAbstractCreative+Protected.h"

#import "NSException+OxmExtensions.h"
#import "NSString+OxmExtensions.h"
#import "UIView+OxmExtensions.h"

#import "OXATargeting.h"
#import "OXMAdConfiguration.h"
#import "OXMClickthroughBrowserView.h"
#import "OXMConstants.h"
#import "OXMCreativeModel.h"
#import "OXMDeviceAccessManager.h"
#import "OXMDownloadDataHelper.h"
#import "OXMError.h"
#import "OXMFunctions+Private.h"
#import "OXMHTMLCreative.h"
#import "OXMHTMLFormatter.h"
#import "OXMLegalButtonDecorator.h"
#import "OXMMacros.h"
#import "OXMModalManager.h"
#import "OXMModalState.h"
#import "OXMModalViewController.h"
#import "OXMMRAIDCommand.h"
#import "OXMMRAIDConstants.h"
#import "OXASDKConfiguration.h"
#import "OXMTransaction.h"
#import "OXMVideoView.h"
#import "OXMWebView.h"
#import "OXMWebViewDelegate.h"
#import "OXMPathBuilder.h"
#import "OXMMRAIDController.h"
#import "OXMCreativeViewabilityTracker.h"

#pragma mark - Private Extension

@interface OXMAbstractCreative() <OXMWebViewDelegate>
@end

@interface OXMHTMLCreative()

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) OXMWebView *openXWebView;
@property (nonatomic, strong) OXASDKConfiguration *sdkConfiguration;
@property (nonatomic, strong) OXMMRAIDController *MRAIDController;
@property (nonatomic, assign) BOOL isAdChoicesOpened;

@end

#pragma mark - Implementation

@implementation OXMHTMLCreative

#pragma mark - Initialization

- (nonnull instancetype)initWithCreativeModel:(OXMCreativeModel *)creativeModel
                                  transaction:(OXMTransaction *)transaction {
    self = [self initWithCreativeModel:creativeModel
                           transaction:transaction
                               webView:nil
                      sdkConfiguration:OXASDKConfiguration.singleton];
    
    return self;
}

- (nonnull instancetype)initWithCreativeModel:(OXMCreativeModel *)creativeModel
                                  transaction:(OXMTransaction *)transaction
                                      webView:(OXMWebView *)webView
                             sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration {
    self = [super initWithCreativeModel:creativeModel transaction:transaction];
    if (self) {
        self.sdkConfiguration = sdkConfiguration;
        
        // TODO: set proper base URL for prebid
        //Set the baseURL. This will cause relative URLs in the creative to inherit the URL scheme used.
        self.baseURL = nil;
        
        if (webView) {
            self.openXWebView = webView;
        }
    }
    
    return self;
}

#pragma mark - OXMAbstractCreative

- (BOOL)isOpened {
    return self.clickthroughVisible || (self.MRAIDController && self.MRAIDController.mraidState != OXMMRAIDStateDefault) || self.isAdChoicesOpened;
}

- (NSNumber *)displayInterval {
    return self.creativeModel.displayDurationInSeconds;
}

- (void)setupView {
    [super setupView];
    
    NSString *html = self.creativeModel.html;
    if (!html) {
        [self onResolutionFailed:[OXMError errorWithDescription:@"No HTML in creative data"]];
        return;
    }
    
    //check if we receive vast data instead of banner
    //https://openxtechinc.atlassian.net/browse/MOBILE-5783
    if (html && [self hasVastTag:html]) {
        [self onResolutionFailed:[OXMError errorWithDescription:@"Wrong data format (VAST) detected for display ad request"]];
        return;
    }

    CGRect rect = CGRectMake(0.0, 0.0, self.creativeModel.width, self.creativeModel.height);
    if (!self.openXWebView) {
        self.openXWebView = [[OXMWebView alloc] initWithFrame:rect
                                                creativeModel:self.creativeModel
                                                    targeting:[OXATargeting shared]];
        
        BOOL isCompanionAdForBuiltInVideo = self.creativeModel.adConfiguration.isBuiltInVideo && self.creativeModel.isCompanionAd;
        
        if (!self.creativeModel.adConfiguration.presentAsInterstitial || isCompanionAdForBuiltInVideo) {
            OXMPosition pos = isCompanionAdForBuiltInVideo ? OXMPositionBottomRight : OXMPositionTopRight;
            self.openXWebView.legalButtonDecorator = [[OXMLegalButtonDecorator alloc] initWithPosition:pos];
            @weakify(self);
            self.openXWebView.legalButtonDecorator.buttonTouchUpInsideBlock = ^{
                @strongify(self);
                self.isAdChoicesOpened = YES;
                OXMClickthroughBrowserView *clickthroughBrowserView = [self.openXWebView.legalButtonDecorator clickthroughBrowserView];
                if (clickthroughBrowserView) {
                    @weakify(self);
                    OXMModalState *state = [OXMModalState modalStateWithView:clickthroughBrowserView
                                                             adConfiguration:nil
                                                           displayProperties:nil
                                                          onStatePopFinished:^(OXMModalState * _Nonnull poppedState) {
                        @strongify(self);
                        [self modalManagerDidFinishPop:poppedState];
                    } onStateHasLeftApp:^(OXMModalState * _Nonnull leavingState) {
                        @strongify(self);
                        [self modalManagerDidLeaveApp:leavingState];
                    }];
                    [self.modalManager pushModal:state fromRootViewController:self.viewControllerForPresentingModals animated:YES shouldReplace:NO completionHandler:nil];
                }
            };
        }
    } else {
        self.openXWebView.frame = rect;
    }
    
    self.openXWebView.delegate = self;
    self.view = self.openXWebView;
    
    [self loadHTMLToWebView];
}

- (BOOL)hasVastTag:(NSString *)html {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<(\\s*)VAST(\\s{1,})version(\\s*)=" options:0 error:NULL];
    NSRange range = NSMakeRange(0, html.length);
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:html options:0 range:range];

    return numberOfMatches > 0;
}
                     
 - (id <OXMUIApplicationProtocol>)getApplication {
     return [UIApplication sharedApplication];
 }

- (void)displayWithRootViewController:(UIViewController*)viewController {
    //Either these constraints are redundant or the initWithFrame is.
    [self.openXWebView OXMAddCropAndCenterConstraintsWithInitialWidth:self.openXWebView.frame.size.width initialHeight:self.openXWebView.frame.size.height];
    [self.openXWebView prepareForMRAIDWithRootViewController:viewController];

    [super displayWithRootViewController:viewController];

    if (self.creativeModel.isCompanionAd == YES) {
        [self.eventManager trackEvent:OXMTrackingEventCreativeView];

        // FIXME: extremly ugly. It makes creative highly coupled with modal manager. Need to split responsibilities more carefully.
        [self.modalManager creativeDisplayCompleted:self];
    }
    
    [self.viewabilityTracker start];
}

- (void)onAdDisplayed {
    [super onAdDisplayed];
    [self setupDisplayTimer];
}

- (void) setupDisplayTimer {
    //Banners display for a set amount of time and then signal creativeDidComplete.
    //Interstitials display for as long as the user is enjoying their presence.
    if (self.creativeModel.adConfiguration.presentAsInterstitial) {
        return;
    }
        
    NSTimeInterval displayInterval = [[self displayInterval] doubleValue];

    if (displayInterval <= 0) {
        //Treat as "display forever"
        return;
    }
        
    @weakify(self);
    dispatch_after([OXMFunctions dispatchTimeAfterTimeInterval:displayInterval], dispatch_get_main_queue(), ^{
        @strongify(self);
        //If its open, don't count this as a creativeDidComplete. Re-start the display timer.
        if ([self isOpened]) {
            [self setupDisplayTimer];
        } else {
            [self.creativeViewDelegate creativeDidComplete:self];
        }
    });
}

// The session must be created only after WebView finishes loading
- (void)createOpenMeasurementSession {
    
    if (!NSThread.currentThread.isMainThread) {
        OXMLogError(@"Open Measurement session can only be created on the main thread");
        return;
    }
                    
    self.transaction.measurementSession = [self.transaction.measurementWrapper initializeWebViewSession:self.openXWebView.internalWebView
                                                                                             contentUrl:@""];
    if (self.transaction.measurementSession) {
        [self.openXWebView addFriendlyObstructionsToMeasurementSession:self.transaction.measurementSession];
        [self.transaction.measurementSession start];
    }
}

- (void)onWillTrackImpression {
    [super onWillTrackImpression];
    [self.eventManager trackEvent:OXMTrackingEventLoaded];
}

- (void)loadHTMLToWebView {
    
    NSString *html = self.creativeModel.html;
    NSString *htmlWithBodyAndHTMLTags = [OXMHTMLFormatter ensureHTMLHasBodyAndHTMLTags:html];
    
    NSError *error;
    NSString *htmlWithMeasurementJS = [self.transaction.measurementWrapper injectJSLib:htmlWithBodyAndHTMLTags error:&error];
    if (error) {
        OXMLogError(@"OXMWebView can't inject Open Measurement JS lib with error: %@", [error localizedDescription]);
    }
    
    [self.openXWebView loadHTML:htmlWithMeasurementJS ?: htmlWithBodyAndHTMLTags
                        baseURL:self.baseURL
                  injectMraidJs:YES];
}

- (void)updateLegalButtonDecorator {
    [self.openXWebView updateLegalButtonForCreative:self];
}

#pragma mark - OXMWebViewDelegate

- (void)webViewReadyToDisplay:(OXMWebView *)webView {
    OXMLogInfo(@"OXMWebView is ready to display");
    
    [self onResolutionCompleted];
}

- (void)webView:(OXMWebView *)webView failedToLoadWithError:(NSError *)error {
    OXMLogError(@"%@", error.localizedDescription);
}

- (void)webView:(OXMWebView *)webView receivedClickthroughLink:(NSURL *)url {
    [self handleClickthrough:url sdkConfiguration:self.sdkConfiguration];
}

- (void)webView:(OXMWebView *)webView receivedMRAIDLink:(NSURL *)url {
    @try {
        if (![self.view isKindOfClass:[OXMWebView class]]) {
            OXMLogWarn(@"Could not cast creative view to OXMWebView");
            return;
        }
        
        if (!self.MRAIDController) {
            self.MRAIDController = [[OXMMRAIDController alloc] initWithCreative:self
                                                    viewControllerForPresenting:self.viewControllerForPresentingModals
                                                                        webView:self.openXWebView
                                                           creativeViewDelegate:self.creativeViewDelegate
                                                                  downloadBlock:self.downloadBlock];
        }
        [self.MRAIDController webView:webView handleMRAIDURL:url];
    } @catch (NSException *exception) {
        OXMLogWarn(@"%@", [exception reason]);
    }
}


#pragma mark - OXMModalManagerDelegate

- (void)modalManagerDidFinishPop:(OXMModalState *)state {
    // adChoice should be closed now
    self.isAdChoicesOpened = NO;
    
    // TODO: Refactor
    // This method illustrates very precisely that we should have different creatives
    // for Banner/Interstitial/MRAID ads.
    // We should use OOP approach for logic encapsulation instead of 'if' logic.

    //Clickthrough
    if ([state.view isKindOfClass:[OXMClickthroughBrowserView class]]) {
        if (!state.adConfiguration) {
            return;
        }
        
        [self.creativeViewDelegate creativeClickthroughDidClose:self];
        self.clickthroughVisible = NO;
        
        //Pop to root after clickthroughs
        if (self.creativeModel.adConfiguration.presentAsInterstitial) {
            if (self.dismissInterstitialModalState) {
                self.dismissInterstitialModalState();
            }
        }
        
        return;
    }
    
    // EndCard?
    if (self.creativeModel.adConfiguration.isOptIn) {
        // Dismiss parent VideoCreative
        OXMVoidBlock dismissParent = [self.transaction getFirstCreative].dismissInterstitialModalState;
        if (dismissParent) {
            dismissParent();
        }
        return;
    }
    
    [self.creativeViewDelegate creativeReadyToReimplant:self];
    if (self.MRAIDController) {
        [self.MRAIDController updateForClose:self.creativeModel.adConfiguration.presentAsInterstitial];
    }

    //Creative presented as Interstitial
    if (self.creativeModel.adConfiguration.presentAsInterstitial) {
        [self.creativeViewDelegate creativeDidComplete:self];
    }
    
    [self.creativeViewDelegate creativeInterstitialDidClose:self];
}

- (void)modalManagerDidLeaveApp:(OXMModalState*) state {
    [self.creativeViewDelegate creativeInterstitialDidLeaveApp:self];
}

#pragma mark - Helper Methods

- (void)handleClickthrough:(NSURL*)url
          sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
         completionHandler:(void (^)(BOOL success))completion
                    onExit:(OXMVoidBlock)onClickthroughExitBlock {
    @weakify(self);
    [super handleClickthrough:url
             sdkConfiguration:self.sdkConfiguration
            completionHandler:^void(BOOL success) {
        @strongify(self);
        if (success) {
            [self.creativeViewDelegate creativeWasClicked:self];
            if (self.creativeModel.isCompanionAd) {
                [self.eventManager trackEvent:OXMTrackingEventCompanionClick];
            } else {
                [self.eventManager trackEvent:OXMTrackingEventClick];
            }
        }
        
        completion(success);
    } onExit:onClickthroughExitBlock];
}

@end
