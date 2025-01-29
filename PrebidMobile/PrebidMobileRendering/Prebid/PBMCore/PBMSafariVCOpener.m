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

#import "PBMSafariVCOpener.h"

#import "PBMDeepLinkPlusHelper.h"
#import "PBMDeferredModalState.h"
#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"
#import "PBMInterstitialDisplayProperties.h"
#import "PBMModalViewController.h"
#import "PBMWindowLocker.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#import "PBMMacros.h"


@interface PBMSafariVCOpener ()

@property (nonatomic, strong, nonnull, readonly) Prebid *sdkConfiguration;
@property (nonatomic, strong, nonnull, readonly) PBMModalManager *modalManager;

@property (nonatomic, strong, nonnull, readonly) PBMViewControllerProvider viewControllerProvider;
@property (nonatomic, strong, nonnull, readonly) PBMOpenMeasurementSessionProvider measurementSessionProvider;

@property (nonatomic, strong, nullable, readonly) PBMVoidBlock onWillLoadURLInClickthrough;
@property (nonatomic, strong, nullable, readonly) PBMVoidBlock onWillLeaveAppBlock;
@property (nonatomic, strong, nullable, readonly) PBMModalStatePopHandler onClickthroughPoppedBlock;
@property (nonatomic, strong, nullable, readonly) PBMModalStateAppLeavingHandler onDidLeaveAppBlock;

@property (nonatomic, strong, nullable) PBMVoidBlock onClickthroughExitBlock;

@property (nonatomic, strong, nullable) SFSafariViewController * safariViewController;

@end


@implementation PBMSafariVCOpener

- (instancetype)initWithSDKConfiguration:(Prebid *)sdkConfiguration
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
    self.onClickthroughExitBlock = onClickthroughExitBlock;
    
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
     
    if (!([strURLscheme isEqualToString:@"http"] || [strURLscheme isEqualToString:@"https"])) {
        PBMLogError(@"Attempting to open url [%@] in SFSafariViewController. SFSafariViewController only supports initial URLs with http:// or https:// schemes.", url);
        return NO;
    }
    
    //Show clickthrough browser
    
    return [self openClickthroughWithURL:url
                          viewController:viewControllerForPresentingModals];
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
{
    @try {
        self.safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        self.safariViewController.delegate = self;
        
        PBMOpenMeasurementSession * const measurementSession = self.measurementSessionProvider();
        PBMWindowLocker * windowLocker = [[PBMWindowLocker alloc] initWithWindow:viewControllerForPresentingModals.view.window
                                                              measurementSession:measurementSession];
        [windowLocker lock];
        
        UIViewController * presentingViewController = viewControllerForPresentingModals;
        
        if (self.modalManager.modalViewController) {
            presentingViewController = self.modalManager.modalViewController;
        }
        
        if (self.onWillLoadURLInClickthrough != nil) {
            self.onWillLoadURLInClickthrough();
        }
        
        [presentingViewController presentViewController:self.safariViewController animated:YES completion:^{
            [windowLocker unlock];
        }];
    } @catch (NSException *exception) {
        PBMLogError(@"Error occurred during URL opening: %@", exception.reason);
    }
    
    return YES;
}

#pragma mark SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    
    if (self.onClickthroughPoppedBlock != nil) {
        self.onClickthroughPoppedBlock(nil);
    }
    
    if (self.onClickthroughExitBlock) {
        self.onClickthroughExitBlock();
    }
}

- (void)safariViewControllerWillOpenInBrowser:(SFSafariViewController *)controller {
    if (self.onDidLeaveAppBlock) {
        self.onDidLeaveAppBlock(nil);
    }
}

@end
