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
#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"
#import "PBMWindowLocker.h"
#import "Log+Extensions.h"

#import "SwiftImport.h"

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
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, PBMWindowLocker *> *windowLockers;

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
    _windowLockers = [NSMutableDictionary new];
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
    if ([PBMFunctions isSimulator] && [PrebidConstants.URL_SCHEMES_NOT_SUPPORTED_ON_SIMULATOR containsObject:strURLscheme]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)shouldOpenURLSchemeExternally:(NSString *)strURLscheme {
    return NO;
}
    
- (BOOL)openClickthroughWithURL:(NSURL *)url
                 viewController:(UIViewController *)viewControllerForPresentingModals
{
    @try {
        if (self.safariViewController && self.safariViewController.presentingViewController) {
            PBMLogInfo(@"⚠️ Safari already being presented, ignoring");
            return NO;
        }
        
        self.safariViewController = [[SFSafariViewController alloc] initWithURL:url];
        self.safariViewController.delegate = self;
        
        UIViewController * presentingViewController = viewControllerForPresentingModals;
        
        if (self.modalManager.modalViewController) {
            presentingViewController = self.modalManager.modalViewController;
        }
        
        if (presentingViewController.presentedViewController != nil) {
            PBMLogInfo(@"⚠️ Presenting view controller is already presenting something");
            return NO;
        }
        
        PBMOpenMeasurementSession * const measurementSession = self.measurementSessionProvider();
        PBMWindowLocker *windowLocker = [self windowLockerForWindow:viewControllerForPresentingModals.view.window
                                                  measurementSession:measurementSession];
        [windowLocker lock];
        
        if (self.onWillLoadURLInClickthrough != nil) {
            self.onWillLoadURLInClickthrough();
        }
        
        [presentingViewController presentViewController:self.safariViewController animated:YES completion:^{
            [windowLocker unlock];
        }];
    } @catch (NSException *exception) {
        PBMLogError(@"Error occurred during URL opening: %@", exception.reason);
        return NO;
    }
    
    return YES;
}

- (PBMWindowLocker *)windowLockerForWindow:(UIWindow *)window
                        measurementSession:(PBMOpenMeasurementSession *)measurementSession {
    NSNumber *key = @(window.hash);
    PBMWindowLocker *locker = self.windowLockers[key];
    
    if (!locker) {
        locker = [[PBMWindowLocker alloc] initWithWindow:window
                                      measurementSession:measurementSession];
        self.windowLockers[key] = locker;
    }
    return locker;
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
