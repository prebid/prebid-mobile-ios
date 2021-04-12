//
//  OXMMRAIDController.m
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

//MRAID spec URLs:
//https://www.iab.com/wp-content/uploads/2015/08/IAB_MRAID_v2_FINAL.pdf
//https://www.iab.com/wp-content/uploads/2017/07/MRAID_3.0_FINAL.pdf

#import "NSException+OxmExtensions.h"
#import "NSString+OxmExtensions.h"
#import "UIView+OxmExtensions.h"

#import "OXMAbstractCreative.h"
#import "OXMCreativeModel.h"
#import "OXMCreativeResolutionDelegate.h"
#import "OXMDeviceAccessManager.h"
#import "OXMError.h"
#import "OXMEventManager.h"
#import "OXMFunctions+Private.h"
#import "OXMInterstitialDisplayProperties.h"
#import "OXMLog.h"
#import "OXMMRAIDCommand.h"
#import "OXMMRAIDConstants.h"
#import "OXMMacros.h"
#import "OXMModalManager.h"
#import "OXMModalState.h"
#import "OXMModalViewController.h"
#import "OXMOpenMeasurementSession.h"
#import "OXASDKConfiguration.h"
#import "OXMTransaction.h"
#import "OXMVideoView.h"
#import "OXMWebView.h"
#import "OXMWebViewDelegate.h"
#import "OXMExposureChangeDelegate.h"

#import "OXMMRAIDController.h"

@interface OXMMRAIDController () <OXMExposureChangeDelegate>

@property (nonatomic, weak) OXMAbstractCreative *creative;
@property (nonatomic, weak, nullable) UIViewController* viewControllerForPresentingModals;
@property (nonatomic, weak, nullable) id<OXMCreativeViewDelegate> creativeViewDelegate;
@property (nonatomic, copy, nullable) OXMCreativeFactoryDownloadDataCompletionClosure downloadBlock;

@property Class deviceAccessManagerClass;

@property (nonatomic, weak) OXMWebView *openXWebView;

@property (nonatomic, assign) BOOL playingMRAIDVideo;
@property (nonatomic, strong) OXASDKConfiguration* sdkConfiguration;

@property (nonatomic, copy, nullable) OXMVoidBlock dismissExpandedModalState;
@property (nonatomic, copy, nullable) OXMVoidBlock dismissResizedModalState;

//See the par. 3.1.4 https://www.iab.com/wp-content/uploads/2017/07/MRAID_3.0_FINAL.pdf
//A new state (via sending changeState) must be set
//only *AFTER* the exposureChange event
//we save the new state and will send it after the exposureChange event
@property (nonatomic, copy, nonnull) OXMMRAIDState delayedMraidState;

@end

@implementation OXMMRAIDController

+ (BOOL)isMRAIDLink:(nonnull NSString *)urlString {
    return [urlString hasPrefix:OXMMRAIDConstants.mraidURLScheme];
}

- (instancetype)initWithCreative:(OXMAbstractCreative*)creative
     viewControllerForPresenting:(UIViewController*)viewControllerForPresentingModals
                         webView:(OXMWebView*)webView
            creativeViewDelegate:(id<OXMCreativeViewDelegate>)creativeViewDelegate
                   downloadBlock:(OXMCreativeFactoryDownloadDataCompletionClosure)downloadBlock {
    
    self = [self initWithCreative:creative
      viewControllerForPresenting:viewControllerForPresentingModals
                          webView:webView
             creativeViewDelegate:creativeViewDelegate
                    downloadBlock:downloadBlock
         deviceAccessManagerClass:nil
                 sdkConfiguration:OXASDKConfiguration.singleton];
    return self;
}

- (instancetype)initWithCreative:(OXMAbstractCreative*)creative
     viewControllerForPresenting:(UIViewController*)viewControllerForPresentingModals
                         webView:(OXMWebView*)webView
            creativeViewDelegate:(id<OXMCreativeViewDelegate>)creativeViewDelegate
                   downloadBlock:(OXMCreativeFactoryDownloadDataCompletionClosure)downloadBlock
        deviceAccessManagerClass:(Class)deviceAccessManagerClass
                sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
{
    self = [super init];
    if (self) {
        self.creative = creative;
        self.viewControllerForPresentingModals = viewControllerForPresentingModals;
        self.openXWebView = webView;
        self.openXWebView.exposureDelegate = self;
        self.creativeViewDelegate = creativeViewDelegate;
        self.downloadBlock = downloadBlock;
        self.deviceAccessManagerClass = (deviceAccessManagerClass) ? deviceAccessManagerClass : [OXMDeviceAccessManager class];
        self.sdkConfiguration = sdkConfiguration;
        
        self.mraidState = OXMMRAIDStateDefault;
        self.delayedMraidState = OXMMRAIDStateNotEnabled;
        self.playingMRAIDVideo = NO;
    }
    return self;
}

- (void)webView:(OXMWebView *)webView handleMRAIDURL:(NSURL*)url {
    [self.openXWebView MRAID_nativeCallComplete];
    @try {
        [self webView:webView handleMRAIDCommand:url];
    } @catch (NSException *exception) {
        OXMLogWarn(@"%@", [exception reason]);
    }
}

- (void)webView:(OXMWebView *)webView handleMRAIDCommand:(NSURL*)url{
    
    OXMMRAIDCommand *oxmMRAIDCommand = [self commandFromURL:url];
    OXMMRAIDAction command = oxmMRAIDCommand.command;

    // 'unload' is the only command allowed to happen when webView is not viewable
    if ([command isEqualToString:OXMMRAIDActionUnload]) {
        [self handleMRAIDCommandUnload];
        return;
    }
    
    if (!webView.viewable) {
        NSString *message = [NSString stringWithFormat:@"MRAID COMMAND: %@ not usable, OXMWebView is not viewable)", command];
        @throw [NSException oxmException:message];
    }
    
    if ([command isEqualToString:OXMMRAIDActionOpen]) {
        [self handleMRAIDCommandOpen:oxmMRAIDCommand];
    } else if ([command isEqualToString:OXMMRAIDActionExpand]) {
        [self handleMRAIDCommandExpand:oxmMRAIDCommand originURL:url];
    } else if ([command isEqualToString:OXMMRAIDActionResize]) {
        [self handleMRAIDCommandResize:oxmMRAIDCommand];
    } else if ([command isEqualToString:OXMMRAIDActionClose]) {
        [self handleMRAIDCommandClose];
    } else if ([command isEqualToString:OXMMRAIDActionStorePicture]) {
        [self handleMRAIDCommandStorePicture:oxmMRAIDCommand];
    } else if ([command isEqualToString:OXMMRAIDActionCreateCalendarEvent]) {
        [self handleMRAIDCommandCreateCalendarEvent:oxmMRAIDCommand];
    } else if ([command isEqualToString:OXMMRAIDActionPlayVideo]) {
        [self handleMRAIDCommandPlayVideo:oxmMRAIDCommand];
    } else if ([command isEqualToString:OXMMRAIDActionOnOrientationPropertiesChanged]) {
        [self handleMRAIDCommandOnOrientationPropertiesChanged:oxmMRAIDCommand];
    } else {
        NSString *message = [NSString stringWithFormat:@"MRAID COMMAND: %@ is not supported", oxmMRAIDCommand.command];
        @throw [NSException oxmException:message];
    }
}

- (void)modalManagerDidFinishPop:(OXMModalState*)state {
    
    //MRAID Video
    if (self.playingMRAIDVideo) {
        // When closing a MRAID video interstitial, only need to set the MRAID state to hidden.
        self.playingMRAIDVideo = NO;
        if (self.mraidState == OXMMRAIDStateExpanded) {
            [self.openXWebView changeToMRAIDState:OXMMRAIDStateExpanded];
        } else {
            [self.openXWebView changeToMRAIDState:OXMMRAIDStateHidden];
        }
        return;
    }
    
    // Just call the host creative
    [self.creative modalManagerDidFinishPop:state];
}

- (void)updateForClose:(BOOL)isInterstitial {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);

        OXMMRAIDState prevState = self.openXWebView.mraidState;
        [self.openXWebView updateMRAIDLayoutInfoWithForceNotification:NO];
        if ([prevState isEqualToString:OXMMRAIDStateExpanded] || [prevState isEqualToString:OXMMRAIDStateResized]) {
            self.delayedMraidState = OXMMRAIDStateDefault;
        } else {
            [self.openXWebView changeToMRAIDState:(isInterstitial ? OXMMRAIDStateHidden : OXMMRAIDStateDefault)];
        }

        
        // Notify Mraid Collapsed *after* the state has changed and Only if we were Expanded.
        if ([prevState isEqualToString:OXMMRAIDStateExpanded]) {
            self.mraidState = OXMMRAIDStateDefault;
            [self.creativeViewDelegate creativeMraidDidCollapse:self.creative];
        }
    });
}

- (void)modalManagerDidLeaveApp:(OXMModalState*)state {
    [self.creative modalManagerDidLeaveApp:state];
}

//MARK: - OXMExposureChangeDelegate protocol

- (BOOL)shouldCheckExposure {
    return ![self.delayedMraidState isEqualToString:OXMMRAIDStateNotEnabled];
}

- (void)webView:(OXMWebView *)webView exposureChange:(OXMViewExposure *)viewExposure {
    if (![self.delayedMraidState isEqualToString:OXMMRAIDStateNotEnabled]) {
        [self.openXWebView changeToMRAIDState:self.delayedMraidState];
        self.delayedMraidState = OXMMRAIDStateNotEnabled;
    }
}

//MARK: - Private methods

- (OXMMRAIDCommand*)commandFromURL:(NSURL*)url {
    if (!url) {
        @throw [NSException oxmException:@"URL is nil"];
        return nil;
    }
    
    NSError *error = nil;
    OXMMRAIDCommand *oxmMRAIDCommand = [[OXMMRAIDCommand alloc] initWithURL:[url absoluteString] error:&error];
    if (!oxmMRAIDCommand) {
        @throw [NSException oxmException:error.localizedDescription];
    }
    
    return oxmMRAIDCommand;
}

// If the modal is shown the @viewControllerForPresentingModals would be excluded from the views hierarchy -
// in this case, the system feature won't be opened with an error:
// Attempt to present <UIAlertController: 0x7fb49c013a00> on <OpenXInternalTestApp.BannerViewController: 0x7fb499c52f30> whose view is not in the window hierarchy!
// So we should provide different controllers depending on the particular state.
- (UIViewController *)viewControllerForSystemFeaturePresentation {
    UIViewController *controller = nil;
    
    if (self.viewControllerForPresentingModals.isViewLoaded && self.viewControllerForPresentingModals.view.window) {
        controller = self.viewControllerForPresentingModals;
    }
    else {
        controller = (UIViewController *)self.creative.modalManager.modalViewController;
    }
    
    if (!controller) {
        OXMLogError(@"There is no controller for presenting system feature.");
    }
    
    return controller;
}

//MARK: - MRAID commands

- (void)handleMRAIDCommandOpen:(OXMMRAIDCommand *)command {
    NSString *strURL = command.arguments.firstObject;
    if (!strURL) {
        @throw [NSException oxmException:@"No arguments to MRAID.open()"];
    }
    
    NSURL *url = [NSURL URLWithString:strURL];
    if (!url) {
        @throw [NSException oxmException:[NSString stringWithFormat:@"Could not create URL from string: %@", strURL]];
    }
    
    OXMLogInfo(@"Attempting to MRAID.open() url %@", strURL);
    [self.creative handleClickthrough:url];
}

- (void)handleMRAIDCommandExpand:(OXMMRAIDCommand *)command originURL:(NSURL *)url {
    if (self.creative.creativeModel.adConfiguration.isInterstitialAd) {
        // 'expand' should have no effect on Interstitial ads.
        // see p.29 of MRAID_3.0_FINAL_June_2018.pdf
        return;
    }
    
    if (self.viewControllerForPresentingModals == nil) {
        @throw [NSException oxmException:[NSString stringWithFormat:@"self.viewControllerForPresentingModals is nil for expand: %@", url]];
    }
    
    OXMWebView *webView = (OXMWebView *)self.openXWebView;
    OXMMRAIDState mraidState = self.openXWebView.mraidState;
    
    NSArray *allowableStatesForResize = @[OXMMRAIDStateDefault, OXMMRAIDStateResized];
    if (![allowableStatesForResize containsObject:mraidState]) {
        @throw [NSException oxmException:[NSString stringWithFormat:@"MRAID cannot expand from state: %@", mraidState]];
    }
    
    OXMInterstitialDisplayProperties *displayProperties = [OXMInterstitialDisplayProperties new];
    
    @weakify(self);
    [webView MRAID_getExpandProperties:^(OXMMRAIDExpandProperties * _Nullable expandProperties) {
        @strongify(self);
        
        if (!self) {
            return;
        }
        
        if (!expandProperties) {
            [webView MRAID_error:@"Unable to get Expand Properties" action:OXMMRAIDActionExpand];
            return;
        }
        
        BOOL const shouldReplace = (self.dismissResizedModalState != nil);
        
        //Check whether we are expanding existing content or expanding to a specific URL.
        NSString *strExpandURL = [[command.arguments firstObject] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if (strExpandURL && ![strExpandURL isEqualToString:@""]) {
            //Epanding to a URL
            NSURL *expandURL = [NSURL URLWithString:strExpandURL];
            if (!expandURL) {
                OXMLogError(@"Could not create expand url to: %@", strExpandURL);
                return;
            }
            
            OXMWebView *newWebView = [OXMWebView new];
            newWebView.delegate = self.openXWebView.delegate;
            [newWebView expand:expandURL];
            
            @weakify(self);
            OXMModalState* oxmModalState = [OXMModalState modalStateWithView:newWebView
                                                             adConfiguration:self.creative.creativeModel.adConfiguration
                                                           displayProperties:displayProperties
                                                          onStatePopFinished:^(OXMModalState * _Nonnull poppedState) {
                @strongify(self);
                [self modalManagerDidFinishPop:poppedState];
            } onStateHasLeftApp:^(OXMModalState * _Nonnull leavingState) {
                @strongify(self);
                [self modalManagerDidLeaveApp:leavingState];
            }];
            
            self.dismissExpandedModalState = [self.creative.modalManager pushModal:oxmModalState fromRootViewController:self.viewControllerForPresentingModals animated:YES shouldReplace:shouldReplace completionHandler:^{
                @strongify(self);
                // ALSO set the first part (banner) to Expanded per MRAID spec
                self.delayedMraidState = OXMMRAIDStateExpanded;

                [newWebView prepareForMRAIDWithRootViewController:self.viewControllerForPresentingModals];
                [self.creative.modalManager.modalViewController addFriendlyObstructionsToMeasurementSession:self.creative.transaction.measurementSession];
            }];
        }
        else {
            //Expand existing content.
            @weakify(self);
            OXMModalState* oxmModalState = [OXMModalState modalStateWithView:webView
                                                             adConfiguration:self.creative.creativeModel.adConfiguration
                                                           displayProperties:displayProperties
                                                          onStatePopFinished:^(OXMModalState * _Nonnull poppedState) {
                @strongify(self);
                [self modalManagerDidFinishPop:poppedState];
            } onStateHasLeftApp:^(OXMModalState * _Nonnull leavingState) {
                @strongify(self);
                [self modalManagerDidLeaveApp:leavingState];
            }];
            
            self.dismissExpandedModalState = [self.creative.modalManager pushModal:oxmModalState fromRootViewController:self.viewControllerForPresentingModals animated:YES shouldReplace:shouldReplace completionHandler:^{
                @strongify(self);
                
                self.delayedMraidState = OXMMRAIDStateExpanded;
                [self.creative.modalManager.modalViewController addFriendlyObstructionsToMeasurementSession:self.creative.transaction.measurementSession];
            }];
        }
        
        self.dismissResizedModalState = nil;
        
        // Notify delegates that the MRAID ad has Expanded
        [self.creativeViewDelegate creativeMraidDidExpand:self.creative];
        self.mraidState = OXMMRAIDStateExpanded;
        [self.creative.eventManager trackEvent:OXMTrackingEventClick];
    }];
}

- (void)handleMRAIDCommandResize:(OXMMRAIDCommand *)command {
    if (self.creative.creativeModel.adConfiguration.isInterstitialAd) {
        // 'resize' should have no effect on Interstitial ads.
        // see p.29 of MRAID_3.0_FINAL_June_2018.pdf
        return;
    }
    
    if (!self.viewControllerForPresentingModals) {
        @throw [NSException oxmException:[NSString stringWithFormat:@"self.viewControllerForPresentingModals is nil for mraid command %@", command]];
    }
    
    OXMWebView *webView = self.openXWebView;
    
    OXMMRAIDState mraidState = self.openXWebView.mraidState;
    
    NSArray *allowableStatesForResize = @[OXMMRAIDStateDefault, OXMMRAIDStateResized];
    if (![allowableStatesForResize containsObject:mraidState]) {
        NSString * const message = [NSString stringWithFormat:@"MRAID cannot resize from state: %@", mraidState];
        [webView MRAID_error:message action:OXMMRAIDActionResize];
        @throw [NSException oxmException:message];
    }
    
    @weakify(self);
    [webView MRAID_getResizeProperties:^(OXMMRAIDResizeProperties * _Nullable resizeProperties) {
        @strongify(self);
        
        if (!resizeProperties) {
            [webView MRAID_error:@"Was unable to get resizeProperties" action:OXMMRAIDActionResize];
            return;
        }
        
        OXMInterstitialDisplayProperties *displayProperties = [OXMInterstitialDisplayProperties new];
        //Make the close button invisible but still tappable.
        [displayProperties setButtonImageHidden];
        
        CGRect frame = [OXMMRAIDController CGRectForResizeProperties:resizeProperties fromView:webView];
        if (CGRectIsInfinite(frame)) {
            NSString *message = @"MRAID ad attempted to resize to an invalid size";
            OXMLogError(@"%@", message);
            [webView MRAID_error:message action:OXMMRAIDActionResize];
            return;
        }
        
        displayProperties.contentFrame = frame;
        displayProperties.contentViewColor = [UIColor clearColor];
        webView.backgroundColor = [UIColor clearColor];
        
        //If we're resizing from an already resized state, the content should replace the existing content rather than
        //push on top of the existing InterstitialState stack.
        BOOL shouldReplace = [mraidState isEqualToString:OXMMRAIDStateResized];
        
        @weakify(self);
        OXMModalState* oxmModalState = [OXMModalState modalStateWithView:webView
                                                         adConfiguration:self.creative.creativeModel.adConfiguration
                                                       displayProperties:displayProperties
                                                      onStatePopFinished:^(OXMModalState * _Nonnull poppedState) {
            @strongify(self);
            [self modalManagerDidFinishPop:poppedState];
        } onStateHasLeftApp:^(OXMModalState * _Nonnull leavingState) {
            @strongify(self);
            [self modalManagerDidLeaveApp:leavingState];
        }];
        oxmModalState.mraidState = OXMMRAIDStateResized;
        
        self.dismissResizedModalState = [self.creative.modalManager pushModal:oxmModalState
              fromRootViewController:self.viewControllerForPresentingModals
                            animated:NO
                       shouldReplace:shouldReplace
                   completionHandler:^{
            @strongify(self);
            self.mraidState = OXMMRAIDStateResized;
            self.delayedMraidState = OXMMRAIDStateResized;
            
            [self.creative.modalManager.modalViewController addFriendlyObstructionsToMeasurementSession:self.creative.transaction.measurementSession];
        }];
        
        [self.creative.eventManager trackEvent:OXMTrackingEventClick];
    }];
}

- (void)handleMRAIDCommandClose {
    OXMVoidBlock dismissModalStateBlock = nil;
    if (self.creative.transaction.adConfiguration.presentAsInterstitial) {
        dismissModalStateBlock = self.creative.dismissInterstitialModalState;
    } else if (self.mraidState == OXMMRAIDStateExpanded) {
        dismissModalStateBlock = self.dismissExpandedModalState;
        self.dismissExpandedModalState = nil;
    } else if (self.mraidState == OXMMRAIDStateResized) {
        dismissModalStateBlock = self.dismissResizedModalState;
        self.dismissResizedModalState = nil;
    }
    if (dismissModalStateBlock) {
        dismissModalStateBlock();
    }
}

- (void)handleMRAIDCommandUnload {
    OXMLogWhereAmI();
    OXMAbstractCreative * const creative = self.creative;
    switch (self.openXWebView.state) {
        case OXMWebViewStateLoaded: {
            if (self.creative.transaction.adConfiguration.presentAsInterstitial) {
                [self handleMRAIDCommandClose];
                break;
            }
            if (self.mraidState == OXMMRAIDStateExpanded || self.mraidState == OXMMRAIDStateResized) {
                [self handleMRAIDCommandClose];
            }
            id<OXMCreativeViewDelegate> const delegate = creative.creativeViewDelegate;
            [delegate creativeDidComplete:creative];
            break;
        }
        case OXMWebViewStateLoading: {
            id<OXMCreativeResolutionDelegate> const delegate = creative.creativeResolutionDelegate;
            [delegate creativeFailed:[OXMError errorWithDescription:@"The Ad called 'mraid.unload();'"]];
            break;
        }
        default:
            break;
    }
}

- (void)handleMRAIDCommandStorePicture:(OXMMRAIDCommand *)command {
    OXMWebView *webView = self.openXWebView;
    
    NSURL *url = [NSURL URLWithString:[command.arguments firstObject]];
    if (!url) {
        [webView MRAID_error:@"Ad wanted to store a picture with an invalid URL" action:OXMMRAIDActionStorePicture];
        return;
    }
    
    @weakify(self);
    [self.creative.modalManager hideModalAnimated:NO completionHandler:^{
        @strongify(self);
        OXMDeviceAccessManager *deviceManager = [[self.deviceAccessManagerClass alloc] initWithRootViewController:[self viewControllerForSystemFeaturePresentation]];
        [deviceManager savePhotoWithUrlToAsset:url completion:^(BOOL succeeded, NSString * _Nonnull message) {
            if (!succeeded) {
                [webView MRAID_error:message action:OXMMRAIDActionStorePicture];
            }
            
            [self.creative.modalManager backModalAnimated:NO fromRootViewController:self.viewControllerForPresentingModals completionHandler:nil];
        }];
        
        [self.creative.eventManager trackEvent:OXMTrackingEventClick];
    }];
}

- (void)handleMRAIDCommandCreateCalendarEvent:(OXMMRAIDCommand *)command {
    OXMWebView *webView = self.openXWebView;
    
    NSString *theEventString = [command.arguments firstObject];
    if (!theEventString) {
        [webView MRAID_error:@"No event string provided" action:OXMMRAIDActionCreateCalendarEvent];
        return;
    }
    
    @weakify(self);
    [self.creative.modalManager hideModalAnimated:NO completionHandler:^{
        @strongify(self);
        [[[self.deviceAccessManagerClass alloc] initWithRootViewController:[self viewControllerForSystemFeaturePresentation]] createCalendarEventFromString:theEventString completion:^(BOOL succeeded, NSString * _Nonnull message) {
            if (!succeeded) {
                [webView MRAID_error:message action:OXMMRAIDActionCreateCalendarEvent];
            }
            
            [self.creative.modalManager backModalAnimated:NO fromRootViewController:self.viewControllerForPresentingModals completionHandler:nil];
        }];
        
        [self.creative.eventManager trackEvent:OXMTrackingEventClick];
    }];
}

- (void)handleMRAIDCommandPlayVideo:(OXMMRAIDCommand *)command {
    // TODO: This pattern seems flawed, `playVideo/` will pass this argument and URL check.
    NSString *strURL = [command.arguments firstObject];
    if (!strURL) {
        @throw [NSException oxmException:@"Insufficient arguments for MRAIDAction.playVideo"];
    }
    
    NSURL *url = [NSURL URLWithString:strURL];
    if (!url) {
        NSString *message = [NSString stringWithFormat:@"MRAID attempted to load an invalid URL: %@", strURL];
        @throw [NSException oxmException:message];
    }
    
    if (!self.viewControllerForPresentingModals) {
        NSString *message = [NSString stringWithFormat:@"self.viewControllerForPresentingModals is nil"];
        @throw [NSException oxmException:message];
    }
    
    self.playingMRAIDVideo = YES;
    
    //TODO: MRAID video should probably stream instead of pre-download.
    [self loadVideo:url];
}

- (void)handleMRAIDCommandOnOrientationPropertiesChanged:(OXMMRAIDCommand *)command {
    
    NSString *jsonString = [command.arguments firstObject];
    if (!jsonString) {
        @throw [NSException oxmException:@"onOrientationPropertiesChanged - No JSON string"];
    }
    
    NSError *error;
    OXMJsonDictionary *jsonDict = [OXMFunctions dictionaryFromJSONString:jsonString error:&error];
    if (!jsonDict) {
        NSString *message = [NSString stringWithFormat:@"onOrientationPropertiesChanged - Unable to parse JSON string: %@", jsonString];
        @throw [NSException oxmException:message];
    }
    
    NSString *strForceOrientation = jsonDict[@"forceOrientation"];
    if (!strForceOrientation) {
        return;
    }
    
    if ([strForceOrientation isEqualToString:OXMMRAIDValues.LANDSCAPE]) {
        [self.creative.modalManager forceOrientation:UIInterfaceOrientationLandscapeLeft];
    } else if ([strForceOrientation isEqualToString:OXMMRAIDValues.PORTRAIT]) {
        [self.creative.modalManager forceOrientation:UIInterfaceOrientationPortrait];
    }
    
    //Note: we currently ignore the allowOrientationChange property as there does not yet exist
    //an elegant way to disable rotation on the navigation controller that the publisher shows
    //the ad interstitial VC from.
}

- (void)loadVideo:(NSURL *)url {
    @weakify(self);
    self.downloadBlock(url, ^(NSData * _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        
        if (error) {
            OXMLogError(@"Unable to load MRAID video. Error: %@", error);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Create a container view. This will stretch to fit the available space.
            UIView* containerView = [[UIView alloc] initWithFrame:CGRectZero];
            
            OXMVideoView *videoView = [[OXMVideoView alloc] initWithEventManager:self.creative.eventManager];
            [videoView showMediaFileURL:url preloadedData:data];
            
            [containerView addSubview:videoView];
            
            [videoView OXMAddFillSuperviewConstraints];
            
            @weakify(self);
            __weak OXMVideoView * weakVideoView = videoView;
            
            OXMModalState* state = [OXMModalState modalStateWithView:containerView
                                                     adConfiguration:self.creative.creativeModel.adConfiguration
                                                   displayProperties:[OXMInterstitialDisplayProperties new]
                                                  onStatePopFinished:^(OXMModalState * _Nonnull poppedState) {
                @strongify(self);
                [self modalManagerDidFinishPop:poppedState];
            } onStateHasLeftApp:^(OXMModalState * _Nonnull leavingState) {
                @strongify(self);
                [self modalManagerDidLeaveApp:leavingState];
            } nextOnStatePopFinished:^(OXMModalState * _Nonnull poppedState) {
                [weakVideoView modalManagerDidFinishPop:poppedState];
            } nextOnStateHasLeftApp:^(OXMModalState * _Nonnull leavingState) {
                [weakVideoView modalManagerDidLeaveApp:leavingState];
            } onModalPushedBlock:^{
                [videoView pause];
            }];
            
            [self.creative.modalManager pushModal:state
                  fromRootViewController:self.viewControllerForPresentingModals
                                animated:YES shouldReplace:NO completionHandler:^{
                @strongify(self);
                [videoView startPlayback];
                [self.creative.modalManager.modalViewController addFriendlyObstructionsToMeasurementSession:self.creative.transaction.measurementSession];
            }];
            
            [self.creative.eventManager trackEvent:OXMTrackingEventClick];
        });
    });
}

+ (CGRect)CGRectForResizeProperties:(OXMMRAIDResizeProperties *)properties fromView:(UIView *)fromView {
    if (!properties) {
        return CGRectInfinite;
    }
    
    // check that the resize fits into the bounds of what's allowed
    if (properties.width < 50 || properties.height < 50) {
        return CGRectInfinite;
    }
    
    // get the view's absolute position
    if (!fromView.superview) {
        OXMLogInfo(@"Could not determine a global point");
        return CGRectInfinite;
    }
    
    CGPoint globalPoint = [fromView.superview convertPoint:fromView.frame.origin toView:nil];
    
    // calc the resized rect based on global offset and resize properties
    CGRect basicRect = CGRectMake((NSInteger)globalPoint.x + properties.offsetX, (NSInteger)globalPoint.y + properties.offsetY, properties.width, properties.height);
    OXMLogInfo(@"basicRect = %@", NSStringFromCGRect(basicRect));
    
    // if offscreen is allowed, return with it
    if (properties.allowOffscreen) {
        if ([OXMMRAIDController isValidCloseRegionPosition:basicRect]) {
            return basicRect;
        } else {
            return CGRectInfinite;
        }
    }
    
    // else, check if it can fit on screen
    CGSize screenSize = [OXMFunctions deviceScreenSize];
    if (basicRect.size.width > screenSize.width || basicRect.size.height > basicRect.size.height) {
        return CGRectInfinite;
    }
    
    // move it fully onscreen
    if (basicRect.origin.x < 0) {
        basicRect.origin.x = 0;
    }
    
    if (basicRect.origin.y < 0) {
        basicRect.origin.y = 0;
    }
    
    if (basicRect.origin.x + basicRect.size.width > screenSize.width) {
        basicRect.origin.x = screenSize.width - basicRect.size.width;
    }
    
    if (basicRect.origin.y + basicRect.size.height > screenSize.height) {
        basicRect.origin.y = screenSize.height - basicRect.size.height;
    }
    
    return basicRect;
}

+ (BOOL)isValidCloseRegionPosition:(CGRect)basicRect {
    //Check the position of the close region
    //https://www.iab.com/wp-content/uploads/2017/07/MRAID_3.0_FINAL.pdf p.37
    //The host must always include a 50x50 density independent pixel close event
    //region. Recommended position is the top right corner of the container provided for the ad.
    CGFloat closeRegionX = basicRect.origin.x + basicRect.size.width - OXMMRAIDCloseButtonSize.WIDTH;
    CGRect closeRegion = (CGRect){.origin.x = closeRegionX, .origin.y = basicRect.origin.y,
                                  .size.width = OXMMRAIDCloseButtonSize.WIDTH, .size.height = OXMMRAIDCloseButtonSize.HEIGHT};
    
    CGSize deviceMaxSize = [OXMFunctions deviceMaxSize];
    UIEdgeInsets saInsets = [OXMFunctions safeAreaInsets];
    CGRect safeArea = (CGRect){
        .origin.x = saInsets.left,
        .origin.y = saInsets.top + [OXMFunctions statusBarHeight],
        .size = deviceMaxSize
    };
    
    return CGRectContainsRect(safeArea, closeRegion);
}

@end
