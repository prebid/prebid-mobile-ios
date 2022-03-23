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

#import "PBMClickthroughBrowserOpener.h"

#import "PBMClickthroughBrowserView.h"
#import "PBMDeepLinkPlusHelper.h"
#import "PBMDeferredModalState.h"
#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"
#import "PBMInterstitialDisplayProperties.h"
#import "PBMModalViewController.h"
#import "PBMWindowLocker.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

#import "PBMMacros.h"


@interface PBMClickthroughBrowserOpener ()

@property (nonatomic, strong, nonnull, readonly) Prebid *sdkConfiguration;
@property (nonatomic, strong, nullable, readonly) PBMAdConfiguration *adConfiguration;
@property (nonatomic, strong, nonnull, readonly) PBMModalManager *modalManager;

@property (nonatomic, strong, nonnull, readonly) PBMViewControllerProvider viewControllerProvider;
@property (nonatomic, strong, nonnull, readonly) PBMOpenMeasurementSessionProvider measurementSessionProvider;

@property (nonatomic, strong, nullable, readonly) PBMVoidBlock onWillLoadURLInClickthrough;
@property (nonatomic, strong, nullable, readonly) PBMVoidBlock onWillLeaveAppBlock;
@property (nonatomic, strong, nullable, readonly) PBMModalStatePopHandler onClickthroughPoppedBlock;
@property (nonatomic, strong, nullable, readonly) PBMModalStateAppLeavingHandler onDidLeaveAppBlock;

@end


@implementation PBMClickthroughBrowserOpener

- (instancetype)initWithSDKConfiguration:(Prebid *)sdkConfiguration
                         adConfiguration:(nullable PBMAdConfiguration *)adConfiguration
                            modalManager:(PBMModalManager *)modalManager
                  viewControllerProvider:(PBMViewControllerProvider)viewControllerProvider
              measurementSessionProvider:(PBMOpenMeasurementSessionProvider)measurementSessionProvider
             onWillLoadURLInClickthrough:(nullable PBMVoidBlock)onWillLoadURLInClickthrough
                     onWillLeaveAppBlock:(nullable PBMVoidBlock)onWillLeaveAppBlock
               onClickthroughPoppedBlock:(nullable PBMModalStatePopHandler)onClickthroughPoppedBlock
                      onDidLeaveAppBlock:(nullable PBMModalStateAppLeavingHandler)onDidLeaveAppBlock
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

- (BOOL)openURL:(NSURL *)url onClickthroughExitBlock:(nullable PBMVoidBlock)onClickthroughExitBlock {
    NSString * const strURLscheme = [self getURLScheme:url];
    if (!strURLscheme) {
        PBMLogError(@"Could not determine URL scheme from url: %@", url);
        return NO;
    }
    
    if (![self shouldTryOpenURLScheme:strURLscheme]) {
        PBMLogError(@"Attempting to open url [%@] in iOS simulator, but simulator does not support url scheme of %@",
                    url, strURLscheme);
        return NO;
    }
    
    if ([self shouldOpenURLSchemeExternally:strURLscheme]) {
        //Open link outside of app
        [PBMFunctions attemptToOpen:url];
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
        PBMLogError(@"self.viewControllerForPresentingModals is nil");
        return NO;
    }
     
    //Show clickthrough browser
    
    return [self openClickthroughWithURL:url
                          viewController:viewControllerForPresentingModals
                 onClickthroughExitBlock:onClickthroughExitBlock];
}

- (PBMURLOpenAttempterBlock)asUrlOpenAttempter {
    return ^(NSURL *url, PBMCanOpenURLResultHandlerBlock compatibilityCheckHandler) {
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
        PBMExternalURLOpenCallbacks * const callbacks = compatibilityCheckHandler(YES);
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
    if ([PBMFunctions isSimulator] && [PBMConstants.urlSchemesNotSupportedOnSimulator containsObject:strURLscheme]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)shouldOpenURLSchemeExternally:(NSString *)strURLscheme {
    if (self.sdkConfiguration.useExternalClickthroughBrowser ||
        [PBMConstants.urlSchemesNotSupportedOnClickthroughBrowser containsObject:strURLscheme])
    {
        return YES;
    }
    
    return NO;
}
    
- (BOOL)openClickthroughWithURL:(NSURL *)url
                 viewController:(UIViewController *)viewControllerForPresentingModals
        onClickthroughExitBlock:(nullable PBMVoidBlock)onClickthroughExitBlock
{
    NSBundle * const bundle = PBMFunctions.bundleForSDK;
    PBMClickthroughBrowserView * const clickthroughBrowserView = [[bundle loadNibNamed:@"ClickthroughBrowserView"
                                                                                 owner:nil
                                                                               options:nil] firstObject];
    if (!clickthroughBrowserView) {
        PBMLogError(@"Unable to create a ClickthroughBrowserView");
        return NO;
    }
    
    @weakify(self);
    PBMModalState * const state = [PBMModalState modalStateWithView:clickthroughBrowserView
                                                    adConfiguration:self.adConfiguration
                                                  displayProperties:[[PBMInterstitialDisplayProperties alloc] init]
                                                 onStatePopFinished:^(PBMModalState * _Nonnull poppedState) {
        // self is INTENTIONALLY retained here => no '@strongify'
        if (self.onClickthroughPoppedBlock != nil) {
            self.onClickthroughPoppedBlock(poppedState);
        }
        if (onClickthroughExitBlock != nil) {
            onClickthroughExitBlock();
        }
    } onStateHasLeftApp:self.onDidLeaveAppBlock];
    
    PBMOpenMeasurementSession * const measurementSession = self.measurementSessionProvider();
    PBMWindowLocker * windowLocker = [[PBMWindowLocker alloc] initWithWindow:viewControllerForPresentingModals.view.window
                                                          measurementSession:measurementSession];
    [windowLocker lock];
    
    PBMDeferredModalState *deferredState = [[PBMDeferredModalState alloc] initWithModalState:state
                                                                      fromRootViewController:viewControllerForPresentingModals
                                                                                    animated:YES
                                                                               shouldReplace:NO
                                                                            preparationBlock:^(PBMDeferredModalStateResolutionHandler  _Nonnull completionBlock) {
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
