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

//MRAID spec URLs:
//https://www.iab.com/wp-content/uploads/2015/08/IAB_MRAID_v2_FINAL.pdf
//https://www.iab.com/wp-content/uploads/2017/07/MRAID_3.0_FINAL.pdf

#import "NSException+PBMExtensions.h"
#import "NSString+PBMExtensions.h"
#import "UIView+PBMExtensions.h"
#import "NSURL+PBMExtensions.h"

#import "PBMAbstractCreative.h"
#import "PBMCreativeModel.h"
#import "PBMCreativeResolutionDelegate.h"
#import "PBMDeviceAccessManager.h"
#import "PBMError.h"
#import "PBMFunctions+Private.h"
#import "PBMInterstitialDisplayProperties.h"
#import "PBMMRAIDCommand.h"
#import "PBMMRAIDConstants.h"
#import "PBMMacros.h"
#import "PBMModalManager.h"
#import "PBMModalState.h"
#import "PBMModalViewController.h"
#import "PBMOpenMeasurementSession.h"
#import "PBMTransaction.h"
#import "PBMVideoView.h"
#import "PBMWebView.h"
#import "PBMWebViewDelegate.h"
#import "PBMExposureChangeDelegate.h"

#import "PBMMRAIDController.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@interface PBMMRAIDController () <PBMExposureChangeDelegate>

@property (nonatomic, weak) PBMAbstractCreative *creative;
@property (nonatomic, weak, nullable) UIViewController* viewControllerForPresentingModals;
@property (nonatomic, weak, nullable) id<PBMCreativeViewDelegate> creativeViewDelegate;
@property (nonatomic, copy, nullable) PBMCreativeFactoryDownloadDataCompletionClosure downloadBlock;

@property Class deviceAccessManagerClass;

@property (nonatomic, weak) PBMWebView *prebidWebView;

@property (nonatomic, assign) BOOL playingMRAIDVideo;
@property (nonatomic, strong) Prebid* sdkConfiguration;

@property (nonatomic, copy, nullable) PBMVoidBlock dismissExpandedModalState;
@property (nonatomic, copy, nullable) PBMVoidBlock dismissResizedModalState;

//See the par. 3.1.4 https://www.iab.com/wp-content/uploads/2017/07/MRAID_3.0_FINAL.pdf
//A new state (via sending changeState) must be set
//only *AFTER* the exposureChange event
//we save the new state and will send it after the exposureChange event
@property (nonatomic, copy, nonnull) PBMMRAIDState delayedMraidState;

@end

@implementation PBMMRAIDController

+ (BOOL)isMRAIDLink:(nonnull NSString *)urlString {
    return [urlString hasPrefix:PBMMRAIDConstants.mraidURLScheme];
}

- (instancetype)initWithCreative:(PBMAbstractCreative*)creative
     viewControllerForPresenting:(UIViewController*)viewControllerForPresentingModals
                         webView:(PBMWebView*)webView
            creativeViewDelegate:(id<PBMCreativeViewDelegate>)creativeViewDelegate
                   downloadBlock:(PBMCreativeFactoryDownloadDataCompletionClosure)downloadBlock {
    
    self = [self initWithCreative:creative
      viewControllerForPresenting:viewControllerForPresentingModals
                          webView:webView
             creativeViewDelegate:creativeViewDelegate
                    downloadBlock:downloadBlock
         deviceAccessManagerClass:nil
                 sdkConfiguration:Prebid.shared];
    return self;
}

- (instancetype)initWithCreative:(PBMAbstractCreative*)creative
     viewControllerForPresenting:(UIViewController*)viewControllerForPresentingModals
                         webView:(PBMWebView*)webView
            creativeViewDelegate:(id<PBMCreativeViewDelegate>)creativeViewDelegate
                   downloadBlock:(PBMCreativeFactoryDownloadDataCompletionClosure)downloadBlock
        deviceAccessManagerClass:(Class)deviceAccessManagerClass
                sdkConfiguration:(Prebid *)sdkConfiguration
{
    self = [super init];
    if (self) {
        self.creative = creative;
        self.viewControllerForPresentingModals = viewControllerForPresentingModals;
        self.prebidWebView = webView;
        self.prebidWebView.exposureDelegate = self;
        self.creativeViewDelegate = creativeViewDelegate;
        self.downloadBlock = downloadBlock;
        self.deviceAccessManagerClass = (deviceAccessManagerClass) ? deviceAccessManagerClass : [PBMDeviceAccessManager class];
        self.sdkConfiguration = sdkConfiguration;
        
        self.mraidState = PBMMRAIDStateDefault;
        self.delayedMraidState = PBMMRAIDStateNotEnabled;
        self.playingMRAIDVideo = NO;
    }
    return self;
}

- (void)webView:(PBMWebView *)webView handleMRAIDURL:(NSURL*)url {
    [self.prebidWebView MRAID_nativeCallComplete];
    @try {
        [self webView:webView handleMRAIDCommand:url];
    } @catch (NSException *exception) {
        PBMLogWarn(@"%@", [exception reason]);
    }
}

- (void)webView:(PBMWebView *)webView handleMRAIDCommand:(NSURL*)url{
    
    PBMMRAIDCommand *pbmMRAIDCommand = [self commandFromURL:url];
    PBMMRAIDAction command = pbmMRAIDCommand.command;

    // 'unload' is the only command allowed to happen when webView is not viewable
    if ([command isEqualToString:PBMMRAIDActionUnload]) {
        [self handleMRAIDCommandUnload];
        return;
    }
    
    if (!webView.viewable) {
        NSString *message = [NSString stringWithFormat:@"MRAID COMMAND: %@ not usable, PBMWebView is not viewable)", command];
        @throw [NSException pbmException:message];
    }
    
    if ([command isEqualToString:PBMMRAIDActionOpen]) {
        [self handleMRAIDCommandOpen:pbmMRAIDCommand];
    } else if ([command isEqualToString:PBMMRAIDActionExpand]) {
        [self handleMRAIDCommandExpand:pbmMRAIDCommand originURL:url];
    } else if ([command isEqualToString:PBMMRAIDActionResize]) {
        [self handleMRAIDCommandResize:pbmMRAIDCommand];
    } else if ([command isEqualToString:PBMMRAIDActionClose]) {
        [self handleMRAIDCommandClose];
    } else if ([command isEqualToString:PBMMRAIDActionStorePicture]) {
        NSString *message = [NSString stringWithFormat:@"MRAID COMMAND: %@ is not supported", pbmMRAIDCommand.command];
        @throw [NSException pbmException:message];
    } else if ([command isEqualToString:PBMMRAIDActionCreateCalendarEvent]) {
        NSString *message = [NSString stringWithFormat:@"MRAID COMMAND: %@ is not supported", pbmMRAIDCommand.command];
        @throw [NSException pbmException:message];
    } else if ([command isEqualToString:PBMMRAIDActionPlayVideo]) {
        [self handleMRAIDCommandPlayVideo:pbmMRAIDCommand];
    } else if ([command isEqualToString:PBMMRAIDActionOnOrientationPropertiesChanged]) {
        [self handleMRAIDCommandOnOrientationPropertiesChanged:pbmMRAIDCommand];
    } else {
        NSString *message = [NSString stringWithFormat:@"MRAID COMMAND: %@ is not supported", pbmMRAIDCommand.command];
        @throw [NSException pbmException:message];
    }
}

- (void)modalManagerDidFinishPop:(PBMModalState*)state {
    
    //MRAID Video
    if (self.playingMRAIDVideo) {
        // When closing a MRAID video interstitial, only need to set the MRAID state to hidden.
        self.playingMRAIDVideo = NO;
        if (self.mraidState == PBMMRAIDStateExpanded) {
            [self.prebidWebView changeToMRAIDState:PBMMRAIDStateExpanded];
        } else {
            [self.prebidWebView changeToMRAIDState:PBMMRAIDStateHidden];
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
        
        if (!self) { return; }

        PBMMRAIDState prevState = self.prebidWebView.mraidState;
        [self.prebidWebView updateMRAIDLayoutInfoWithForceNotification:NO];
        if ([prevState isEqualToString:PBMMRAIDStateExpanded] || [prevState isEqualToString:PBMMRAIDStateResized]) {
            self.delayedMraidState = PBMMRAIDStateDefault;
        } else {
            [self.prebidWebView changeToMRAIDState:(isInterstitial ? PBMMRAIDStateHidden : PBMMRAIDStateDefault)];
        }

        
        // Notify Mraid Collapsed *after* the state has changed and Only if we were Expanded.
        if ([prevState isEqualToString:PBMMRAIDStateExpanded]) {
            self.mraidState = PBMMRAIDStateDefault;
            [self.creativeViewDelegate creativeMraidDidCollapse:self.creative];
        }
    });
}

- (void)modalManagerDidLeaveApp:(PBMModalState*)state {
    [self.creative modalManagerDidLeaveApp:state];
}

//MARK: - PBMExposureChangeDelegate protocol

- (BOOL)shouldCheckExposure {
    return ![self.delayedMraidState isEqualToString:PBMMRAIDStateNotEnabled];
}

- (void)webView:(PBMWebView *)webView exposureChange:(PBMViewExposure *)viewExposure {
    if (![self.delayedMraidState isEqualToString:PBMMRAIDStateNotEnabled]) {
        [self.prebidWebView changeToMRAIDState:self.delayedMraidState];
        self.delayedMraidState = PBMMRAIDStateNotEnabled;
    }
}

//MARK: - Private methods

- (PBMMRAIDCommand*)commandFromURL:(NSURL*)url {
    if (!url) {
        @throw [NSException pbmException:@"URL is nil"];
        return nil;
    }
    
    NSError *error = nil;
    PBMMRAIDCommand *pbmMRAIDCommand = [[PBMMRAIDCommand alloc] initWithURL:[url absoluteString] error:&error];
    if (!pbmMRAIDCommand) {
        @throw [NSException pbmException:error.localizedDescription];
    }
    
    return pbmMRAIDCommand;
}

// If the modal is shown the @viewControllerForPresentingModals would be excluded from the views hierarchy -
// in this case, the system feature won't be opened with an error:
// Attempt to present <UIAlertController: 0x7fb49c013a00> on <PrebidMobileDemoRendering.BannerViewController: 0x7fb499c52f30> whose view is not in the window hierarchy!
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
        PBMLogError(@"There is no controller for presenting system feature.");
    }
    
    return controller;
}

//MARK: - MRAID commands

- (void)handleMRAIDCommandOpen:(PBMMRAIDCommand *)command {
    NSString *strURL = command.arguments.firstObject;
    if (!strURL) {
        @throw [NSException pbmException:@"No arguments to MRAID.open()"];
    }
    
    NSURL *url = [NSURL PBMURLWithoutEncodingFromString:strURL];
    if (!url) {
        @throw [NSException pbmException:[NSString stringWithFormat:@"Could not create URL from string: %@", strURL]];
    }
    
    PBMLogInfo(@"Attempting to MRAID.open() url %@", strURL);
    [self.creative handleClickthrough:url];
}

- (void)handleMRAIDCommandExpand:(PBMMRAIDCommand *)command originURL:(NSURL *)url {
    if (self.creative.creativeModel.adConfiguration.isInterstitialAd) {
        // 'expand' should have no effect on Interstitial ads.
        // see p.29 of MRAID_3.0_FINAL_June_2018.pdf
        return;
    }
    
    if (self.viewControllerForPresentingModals == nil) {
        @throw [NSException pbmException:[NSString stringWithFormat:@"self.viewControllerForPresentingModals is nil for expand: %@", url]];
    }
    
    PBMWebView *webView = (PBMWebView *)self.prebidWebView;
    PBMMRAIDState mraidState = self.prebidWebView.mraidState;
    
    NSArray *allowableStatesForResize = @[PBMMRAIDStateDefault, PBMMRAIDStateResized];
    if (![allowableStatesForResize containsObject:mraidState]) {
        @throw [NSException pbmException:[NSString stringWithFormat:@"MRAID cannot expand from state: %@", mraidState]];
    }
    
    PBMInterstitialDisplayProperties *displayProperties = [PBMInterstitialDisplayProperties new];
    
    @weakify(self);
    [webView MRAID_getExpandProperties:^(PBMMRAIDExpandProperties * _Nullable expandProperties) {
        @strongify(self);
        if (!self) { return; }
        
        if (!expandProperties) {
            [webView MRAID_error:@"Unable to get Expand Properties" action:PBMMRAIDActionExpand];
            return;
        }
        
        BOOL const shouldReplace = (self.dismissResizedModalState != nil);
        
        //Check whether we are expanding existing content or expanding to a specific URL.
        NSString *strExpandURL = [[command.arguments firstObject] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if (strExpandURL && ![strExpandURL isEqualToString:@""]) {
            //Epanding to a URL
            NSURL *expandURL = [NSURL PBMURLWithoutEncodingFromString:strExpandURL];
            if (!expandURL) {
                PBMLogError(@"Could not create expand url to: %@", strExpandURL);
                return;
            }
            
            PBMWebView *newWebView = [PBMWebView new];
            newWebView.delegate = self.prebidWebView.delegate;
            [newWebView expand:expandURL];
            
            @weakify(self);
            PBMModalState* pbmModalState = [PBMModalState modalStateWithView:newWebView
                                                             adConfiguration:self.creative.creativeModel.adConfiguration
                                                           displayProperties:displayProperties
                                                          onStatePopFinished:^(PBMModalState * _Nonnull poppedState) {
                @strongify(self);
                if (!self) { return; }
                
                [self modalManagerDidFinishPop:poppedState];
            } onStateHasLeftApp:^(PBMModalState * _Nonnull leavingState) {
                @strongify(self);
                if (!self) { return; }
                
                [self modalManagerDidLeaveApp:leavingState];
            }];
            
            self.dismissExpandedModalState = [self.creative.modalManager pushModal:pbmModalState fromRootViewController:self.viewControllerForPresentingModals animated:YES shouldReplace:shouldReplace completionHandler:^{
                @strongify(self);
                if (!self) { return; }
                
                // ALSO set the first part (banner) to Expanded per MRAID spec
                self.delayedMraidState = PBMMRAIDStateExpanded;

                [newWebView prepareForMRAIDWithRootViewController:self.viewControllerForPresentingModals];
                [self.creative.modalManager.modalViewController addFriendlyObstructionsToMeasurementSession:self.creative.transaction.measurementSession];
            }];
        }
        else {
            //Expand existing content.
            @weakify(self);
            PBMModalState* pbmModalState = [PBMModalState modalStateWithView:webView
                                                             adConfiguration:self.creative.creativeModel.adConfiguration
                                                           displayProperties:displayProperties
                                                          onStatePopFinished:^(PBMModalState * _Nonnull poppedState) {
                @strongify(self);
                if (!self) { return; }
                
                [self modalManagerDidFinishPop:poppedState];
            } onStateHasLeftApp:^(PBMModalState * _Nonnull leavingState) {
                @strongify(self);
                if (!self) { return; }
                
                [self modalManagerDidLeaveApp:leavingState];
            }];
            
            self.dismissExpandedModalState = [self.creative.modalManager pushModal:pbmModalState fromRootViewController:self.viewControllerForPresentingModals animated:YES shouldReplace:shouldReplace completionHandler:^{
                @strongify(self);
                if (!self) { return; }
                
                self.delayedMraidState = PBMMRAIDStateExpanded;
                [self.creative.modalManager.modalViewController addFriendlyObstructionsToMeasurementSession:self.creative.transaction.measurementSession];
            }];
        }
        
        self.dismissResizedModalState = nil;
        
        // Notify delegates that the MRAID ad has Expanded
        [self.creativeViewDelegate creativeMraidDidExpand:self.creative];
        self.mraidState = PBMMRAIDStateExpanded;
        [self.creative.eventManager trackEvent:PBMTrackingEventClick];
    }];
}

- (void)handleMRAIDCommandResize:(PBMMRAIDCommand *)command {
    if (self.creative.creativeModel.adConfiguration.isInterstitialAd) {
        // 'resize' should have no effect on Interstitial ads.
        // see p.29 of MRAID_3.0_FINAL_June_2018.pdf
        return;
    }
    
    if (!self.viewControllerForPresentingModals) {
        @throw [NSException pbmException:[NSString stringWithFormat:@"self.viewControllerForPresentingModals is nil for mraid command %@", command]];
    }
    
    PBMWebView *webView = self.prebidWebView;
    
    PBMMRAIDState mraidState = self.prebidWebView.mraidState;
    
    NSArray *allowableStatesForResize = @[PBMMRAIDStateDefault, PBMMRAIDStateResized];
    if (![allowableStatesForResize containsObject:mraidState]) {
        NSString * const message = [NSString stringWithFormat:@"MRAID cannot resize from state: %@", mraidState];
        [webView MRAID_error:message action:PBMMRAIDActionResize];
        @throw [NSException pbmException:message];
    }
    
    @weakify(self);
    [webView MRAID_getResizeProperties:^(PBMMRAIDResizeProperties * _Nullable resizeProperties) {
        @strongify(self);
        if (!self) { return; }
        
        if (!resizeProperties) {
            [webView MRAID_error:@"Was unable to get resizeProperties" action:PBMMRAIDActionResize];
            return;
        }
        
        PBMInterstitialDisplayProperties *displayProperties = [PBMInterstitialDisplayProperties new];
        //Make the close button invisible but still tappable.
        [displayProperties setButtonImageHidden];
        
        CGRect frame = [PBMMRAIDController CGRectForResizeProperties:resizeProperties fromView:webView];
        if (CGRectIsInfinite(frame)) {
            NSString *message = @"MRAID ad attempted to resize to an invalid size";
            PBMLogError(@"%@", message);
            [webView MRAID_error:message action:PBMMRAIDActionResize];
            return;
        }
        
        displayProperties.contentFrame = frame;
        displayProperties.contentViewColor = [UIColor clearColor];
        webView.backgroundColor = [UIColor clearColor];
        
        //If we're resizing from an already resized state, the content should replace the existing content rather than
        //push on top of the existing InterstitialState stack.
        BOOL shouldReplace = [mraidState isEqualToString:PBMMRAIDStateResized];
        
        @weakify(self);
        PBMModalState* pbmModalState = [PBMModalState modalStateWithView:webView
                                                         adConfiguration:self.creative.creativeModel.adConfiguration
                                                       displayProperties:displayProperties
                                                      onStatePopFinished:^(PBMModalState * _Nonnull poppedState) {
            @strongify(self);
            if (!self) { return; }
            
            [self modalManagerDidFinishPop:poppedState];
        } onStateHasLeftApp:^(PBMModalState * _Nonnull leavingState) {
            @strongify(self);
            if (!self) { return;  }
            
            [self modalManagerDidLeaveApp:leavingState];
        }];
        pbmModalState.mraidState = PBMMRAIDStateResized;
        
        self.dismissResizedModalState = [self.creative.modalManager pushModal:pbmModalState
              fromRootViewController:self.viewControllerForPresentingModals
                            animated:NO
                       shouldReplace:shouldReplace
                   completionHandler:^{
            @strongify(self);
            if (!self) { return; }
            
            self.mraidState = PBMMRAIDStateResized;
            self.delayedMraidState = PBMMRAIDStateResized;
            
            [self.creative.modalManager.modalViewController addFriendlyObstructionsToMeasurementSession:self.creative.transaction.measurementSession];
        }];
        
        [self.creative.eventManager trackEvent:PBMTrackingEventClick];
    }];
}

- (void)handleMRAIDCommandClose {
    PBMVoidBlock dismissModalStateBlock = nil;
    if (self.creative.transaction.adConfiguration.presentAsInterstitial) {
        dismissModalStateBlock = self.creative.dismissInterstitialModalState;
    } else if (self.mraidState == PBMMRAIDStateExpanded) {
        dismissModalStateBlock = self.dismissExpandedModalState;
        self.dismissExpandedModalState = nil;
    } else if (self.mraidState == PBMMRAIDStateResized) {
        dismissModalStateBlock = self.dismissResizedModalState;
        self.dismissResizedModalState = nil;
    }
    if (dismissModalStateBlock) {
        dismissModalStateBlock();
    }
}

- (void)handleMRAIDCommandUnload {
    PBMLogWhereAmI();
    PBMAbstractCreative * const creative = self.creative;
    switch (self.prebidWebView.state) {
        case PBMWebViewStateLoaded: {
            if (self.creative.transaction.adConfiguration.presentAsInterstitial) {
                [self handleMRAIDCommandClose];
                break;
            }
            if (self.mraidState == PBMMRAIDStateExpanded || self.mraidState == PBMMRAIDStateResized) {
                [self handleMRAIDCommandClose];
            }
            id<PBMCreativeViewDelegate> const delegate = creative.creativeViewDelegate;
            [delegate creativeDidComplete:creative];
            break;
        }
        case PBMWebViewStateLoading: {
            id<PBMCreativeResolutionDelegate> const delegate = creative.creativeResolutionDelegate;
            [delegate creativeFailed:[PBMError errorWithDescription:@"The Ad called 'mraid.unload();'"]];
            break;
        }
        default:
            break;
    }
}

- (void)handleMRAIDCommandPlayVideo:(PBMMRAIDCommand *)command {
    // TODO: This pattern seems flawed, `playVideo/` will pass this argument and URL check.
    NSString *strURL = [command.arguments firstObject];
    if (!strURL) {
        @throw [NSException pbmException:@"Insufficient arguments for MRAIDAction.playVideo"];
    }
    
    NSURL *url = [NSURL PBMURLWithoutEncodingFromString:strURL];
    if (!url) {
        NSString *message = [NSString stringWithFormat:@"MRAID attempted to load an invalid URL: %@", strURL];
        @throw [NSException pbmException:message];
    }
    
    if (!self.viewControllerForPresentingModals) {
        NSString *message = [NSString stringWithFormat:@"self.viewControllerForPresentingModals is nil"];
        @throw [NSException pbmException:message];
    }
    
    self.playingMRAIDVideo = YES;
    
    //TODO: MRAID video should probably stream instead of pre-download.
    [self loadVideo:url];
}

- (void)handleMRAIDCommandOnOrientationPropertiesChanged:(PBMMRAIDCommand *)command {
    
    NSString *jsonString = [command.arguments firstObject];
    if (!jsonString) {
        @throw [NSException pbmException:@"onOrientationPropertiesChanged - No JSON string"];
    }
    
    NSError *error;
    PBMJsonDictionary *jsonDict = [PBMFunctions dictionaryFromJSONString:jsonString error:&error];
    if (!jsonDict) {
        NSString *message = [NSString stringWithFormat:@"onOrientationPropertiesChanged - Unable to parse JSON string: %@", jsonString];
        @throw [NSException pbmException:message];
    }
    
    NSString *strForceOrientation = jsonDict[@"forceOrientation"];
    if (!strForceOrientation) {
        return;
    }
    
    if ([strForceOrientation isEqualToString:PBMMRAIDValues.LANDSCAPE]) {
        [self.creative.modalManager forceOrientation:UIInterfaceOrientationLandscapeLeft];
    } else if ([strForceOrientation isEqualToString:PBMMRAIDValues.PORTRAIT]) {
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
        if (!self) { return; }
        
        if (error) {
            PBMLogError(@"Unable to load MRAID video. Error: %@", error);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Create a container view. This will stretch to fit the available space.
            UIView* containerView = [[UIView alloc] initWithFrame:CGRectZero];
            
            PBMVideoView *videoView = [[PBMVideoView alloc] initWithEventManager:self.creative.eventManager];
            [videoView showMediaFileURL:url preloadedData:data];
            
            [containerView addSubview:videoView];
            
            [videoView PBMAddFillSuperviewConstraints];
            
            @weakify(self);
            __weak PBMVideoView * weakVideoView = videoView;
            
            PBMModalState* state = [PBMModalState modalStateWithView:containerView
                                                     adConfiguration:self.creative.creativeModel.adConfiguration
                                                   displayProperties:[PBMInterstitialDisplayProperties new]
                                                  onStatePopFinished:^(PBMModalState * _Nonnull poppedState) {
                @strongify(self);
                if (!self) { return; }
                [self modalManagerDidFinishPop:poppedState];
            } onStateHasLeftApp:^(PBMModalState * _Nonnull leavingState) {
                @strongify(self);
                if (!self) { return; }
                
                [self modalManagerDidLeaveApp:leavingState];
            } nextOnStatePopFinished:^(PBMModalState * _Nonnull poppedState) {
                [weakVideoView modalManagerDidFinishPop:poppedState];
            } nextOnStateHasLeftApp:^(PBMModalState * _Nonnull leavingState) {
                [weakVideoView modalManagerDidLeaveApp:leavingState];
            } onModalPushedBlock:^{
                [videoView pause];
            }];
            
            [self.creative.modalManager pushModal:state
                  fromRootViewController:self.viewControllerForPresentingModals
                                animated:YES shouldReplace:NO completionHandler:^{
                @strongify(self);
                if (!self) { return; }
                
                [videoView startPlayback];
                [self.creative.modalManager.modalViewController addFriendlyObstructionsToMeasurementSession:self.creative.transaction.measurementSession];
            }];
            
            [self.creative.eventManager trackEvent:PBMTrackingEventClick];
        });
    });
}

+ (CGRect)CGRectForResizeProperties:(PBMMRAIDResizeProperties *)properties fromView:(UIView *)fromView {
    if (!properties) {
        return CGRectInfinite;
    }
    
    // check that the resize fits into the bounds of what's allowed
    if (properties.width < 50 || properties.height < 50) {
        return CGRectInfinite;
    }
    
    // get the view's absolute position
    if (!fromView.superview) {
        PBMLogInfo(@"Could not determine a global point");
        return CGRectInfinite;
    }
    
    CGPoint globalPoint = [fromView.superview convertPoint:fromView.frame.origin toView:nil];
    
    // calc the resized rect based on global offset and resize properties
    CGRect basicRect = CGRectMake((NSInteger)globalPoint.x + properties.offsetX, (NSInteger)globalPoint.y + properties.offsetY, properties.width, properties.height);
    PBMLogInfo(@"basicRect = %@", NSStringFromCGRect(basicRect));
    
    // if offscreen is allowed, return with it
    if (properties.allowOffscreen) {
        if ([PBMMRAIDController isValidCloseRegionPosition:basicRect]) {
            return basicRect;
        } else {
            return CGRectInfinite;
        }
    }
    
    // else, check if it can fit on screen
    CGSize screenSize = [PBMFunctions deviceScreenSize];
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
    CGFloat closeRegionX = basicRect.origin.x + basicRect.size.width - PBMMRAIDCloseButtonSize.WIDTH;
    CGRect closeRegion = (CGRect){.origin.x = closeRegionX, .origin.y = basicRect.origin.y,
                                  .size.width = PBMMRAIDCloseButtonSize.WIDTH, .size.height = PBMMRAIDCloseButtonSize.HEIGHT};
    
    CGSize deviceMaxSize = [PBMFunctions deviceMaxSize];
    UIEdgeInsets saInsets = [PBMFunctions safeAreaInsets];
    CGRect safeArea = (CGRect){
        .origin.x = saInsets.left,
        .origin.y = saInsets.top + [PBMFunctions statusBarHeight],
        .size = deviceMaxSize
    };
    
    return CGRectContainsRect(safeArea, closeRegion);
}

@end
