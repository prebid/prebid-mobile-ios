//
//  OXAClickthroughBrowserOpener.m
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAClickthroughBrowserOpener.h"

#import "OXMClickthroughBrowserView.h"
#import "OXMDeepLinkPlusHelper.h"
#import "OXMDeferredModalState.h"
#import "OXMFunctions.h"
#import "OXMFunctions+Private.h"
#import "OXMInterstitialDisplayProperties.h"
#import "OXMModalViewController.h"
#import "OXMWindowLocker.h"

#import "OXMMacros.h"


@interface OXAClickthroughBrowserOpener ()

@property (nonatomic, strong, nonnull, readonly) OXASDKConfiguration *sdkConfiguration;
@property (nonatomic, strong, nullable, readonly) OXMAdConfiguration *adConfiguration;
@property (nonatomic, strong, nonnull, readonly) OXMModalManager *modalManager;

@property (nonatomic, strong, nonnull, readonly) OXAViewControllerProvider viewControllerProvider;
@property (nonatomic, strong, nonnull, readonly) OXAOpenMeasurementSessionProvider measurementSessionProvider;

@property (nonatomic, strong, nullable, readonly) OXMVoidBlock onWillLoadURLInClickthrough;
@property (nonatomic, strong, nullable, readonly) OXMVoidBlock onWillLeaveAppBlock;
@property (nonatomic, strong, nullable, readonly) OXMModalStatePopHandler onClickthroughPoppedBlock;
@property (nonatomic, strong, nullable, readonly) OXMModalStateAppLeavingHandler onDidLeaveAppBlock;

@end


@implementation OXAClickthroughBrowserOpener

- (instancetype)initWithSDKConfiguration:(OXASDKConfiguration *)sdkConfiguration
                         adConfiguration:(nullable OXMAdConfiguration *)adConfiguration
                            modalManager:(OXMModalManager *)modalManager
                  viewControllerProvider:(OXAViewControllerProvider)viewControllerProvider
              measurementSessionProvider:(OXAOpenMeasurementSessionProvider)measurementSessionProvider
             onWillLoadURLInClickthrough:(nullable OXMVoidBlock)onWillLoadURLInClickthrough
                     onWillLeaveAppBlock:(nullable OXMVoidBlock)onWillLeaveAppBlock
               onClickthroughPoppedBlock:(nullable OXMModalStatePopHandler)onClickthroughPoppedBlock
                      onDidLeaveAppBlock:(nullable OXMModalStateAppLeavingHandler)onDidLeaveAppBlock
{
    if (!(self = [super init])) {
        return nil;
    }
    _sdkConfiguration = sdkConfiguration;
    _adConfiguration = adConfiguration;
    _modalManager = modalManager;
    _viewControllerProvider = viewControllerProvider;
    _measurementSessionProvider = measurementSessionProvider;
    _onWillLoadURLInClickthrough = onWillLoadURLInClickthrough;
    _onWillLeaveAppBlock = onWillLeaveAppBlock;
    _onClickthroughPoppedBlock = onClickthroughPoppedBlock;
    _onDidLeaveAppBlock = onDidLeaveAppBlock;
    return self;
}

- (BOOL)openURL:(NSURL *)url onClickthroughExitBlock:(nullable OXMVoidBlock)onClickthroughExitBlock {
    NSString * const strURLscheme = [self getURLScheme:url];
    if (!strURLscheme) {
        OXMLogError(@"Could not determine URL scheme from url: %@", url);
        return NO;
    }
    
    if (![self shouldTryOpenURLScheme:strURLscheme]) {
        OXMLogError(@"Attempting to open url [%@] in iOS simulator, but simulator does not support url scheme of %@",
                    url, strURLscheme);
        return NO;
    }
    
    if ([self shouldOpenURLSchemeExternally:strURLscheme]) {
        //Open link outside of app
        [OXMFunctions attemptToOpen:url];
        if (self.onWillLeaveAppBlock != nil) {
            self.onWillLeaveAppBlock();
        }
        if (onClickthroughExitBlock != nil) {
            onClickthroughExitBlock();
        }
        return YES;
    }
    
    UIViewController * const viewControllerForPresentingModals = self.viewControllerProvider();
    if (viewControllerForPresentingModals == nil) {
        OXMLogError(@"self.viewControllerForPresentingModals is nil");
        return NO;
    }
     
    //Show clickthrough browser
    
    return [self openClickthroughWithURL:url
                          viewController:viewControllerForPresentingModals
                 onClickthroughExitBlock:onClickthroughExitBlock];
}

- (OXAURLOpenAttempterBlock)asUrlOpenAttempter {
    return ^(NSURL *url, OXACanOpenURLResultHandlerBlock compatibilityCheckHandler) {
        // Check if URL is compatible
        NSString * const strURLscheme = [self getURLScheme:url];
        if (strURLscheme == nil
            || ![self shouldTryOpenURLScheme:strURLscheme]
            || [self shouldOpenURLSchemeExternally:strURLscheme])
        {
            compatibilityCheckHandler(NO);
            return;
        }
        
        // Check if other properties are OK
        UIViewController * const viewControllerForPresentingModals = self.viewControllerProvider();
        if (viewControllerForPresentingModals == nil) {
            compatibilityCheckHandler(NO);
            return;
        }
        
        // Show clickthrough browser
        OXAExternalURLOpenCallbacks * const callbacks = compatibilityCheckHandler(YES);
        BOOL const didOpenClickthrough = [self openClickthroughWithURL:url
                                                        viewController:viewControllerForPresentingModals
                                               onClickthroughExitBlock:callbacks.onClickthroughExitBlock];
        callbacks.urlOpenedCallback(didOpenClickthrough);
    };
}

// MARK: - Private

- (NSString *)getURLScheme:(NSURL *)url {
    return [url.scheme lowercaseString];
}

- (BOOL)shouldTryOpenURLScheme:(NSString *)strURLscheme {
    if ([OXMFunctions isSimulator] && [OXMConstants.urlSchemesNotSupportedOnSimulator containsObject:strURLscheme]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)shouldOpenURLSchemeExternally:(NSString *)strURLscheme {
    if (self.sdkConfiguration.useExternalClickthroughBrowser ||
        [OXMConstants.urlSchemesNotSupportedOnClickthroughBrowser containsObject:strURLscheme])
    {
        return YES;
    }
    
    return NO;
}
    
- (BOOL)openClickthroughWithURL:(NSURL *)url
                 viewController:(UIViewController *)viewControllerForPresentingModals
        onClickthroughExitBlock:(nullable OXMVoidBlock)onClickthroughExitBlock
{
    NSBundle * const bundle = OXMFunctions.bundleForSDK;
    OXMClickthroughBrowserView * const clickthroughBrowserView = [[bundle loadNibNamed:@"ClickthroughBrowserView"
                                                                                 owner:nil
                                                                               options:nil] firstObject];
    if (!clickthroughBrowserView) {
        OXMLogError(@"Unable to create a ClickthroughBrowserView");
        return NO;
    }
    
    @weakify(self);
    OXMModalState * const state = [OXMModalState modalStateWithView:clickthroughBrowserView
                                                    adConfiguration:self.adConfiguration
                                                  displayProperties:[[OXMInterstitialDisplayProperties alloc] init]
                                                 onStatePopFinished:^(OXMModalState * _Nonnull poppedState) {
        // self is INTENTIONALLY retained here => no '@strongify'
        if (self.onClickthroughPoppedBlock != nil) {
            self.onClickthroughPoppedBlock(poppedState);
        }
        if (onClickthroughExitBlock != nil) {
            onClickthroughExitBlock();
        }
    } onStateHasLeftApp:self.onDidLeaveAppBlock];
    
    OXMOpenMeasurementSession * const measurementSession = self.measurementSessionProvider();
    OXMWindowLocker * windowLocker = [[OXMWindowLocker alloc] initWithWindow:viewControllerForPresentingModals.view.window
                                                          measurementSession:measurementSession];
    [windowLocker lock];
    
    OXMDeferredModalState *deferredState = [[OXMDeferredModalState alloc] initWithModalState:state
                                                                      fromRootViewController:viewControllerForPresentingModals
                                                                                    animated:YES
                                                                               shouldReplace:NO
                                                                            preparationBlock:^(OXMDeferredModalStateResolutionHandler  _Nonnull completionBlock) {
        @strongify(self);
        if (self.onWillLoadURLInClickthrough != nil) {
            self.onWillLoadURLInClickthrough();
        }
        [clickthroughBrowserView openURL:url completion:completionBlock];
    }
                                                                              onWillBePushed:^{
        [windowLocker unlock];
    }
                                                                               onPushStarted:nil
                                                                             onPushCompleted:^{
        @strongify(self);
        [self.modalManager.modalViewController addFriendlyObstructionsToMeasurementSession:measurementSession];
    }
                                                                             onPushCancelled:^{
        [windowLocker unlock];
        if (onClickthroughExitBlock != nil) {
            onClickthroughExitBlock();
        }
    }];
    
    [self.modalManager pushDeferredModal:deferredState];
    
    return YES;
}

@end
