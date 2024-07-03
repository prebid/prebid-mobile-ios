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

#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/ATTrackingManager.h>

#import "PBMDeviceAccessManager.h"
#import "PBMDeviceAccessManagerKeys.h"
#import "PBMFunctions+Private.h"
#include <sys/sysctl.h>

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - PBMDeviceAccessManager

@interface PBMDeviceAccessManager ()
@property (nonatomic, strong, readonly, nonnull) NSLocale *locale;
@property (nonatomic, weak, nullable) UIViewController *rootViewController;
@end

#pragma mark - Implementation

@implementation PBMDeviceAccessManager

#pragma mark - Initialization

- (instancetype)initWithRootViewController:(UIViewController *)viewController {
    return [self initWithRootViewController:viewController
                                     locale:NSLocale.autoupdatingCurrentLocale];
}

- (instancetype)initWithRootViewController:(UIViewController *)viewController
                                    locale:(NSLocale *)locale {
    self = [super init];
    if (self) {
        self.rootViewController = viewController;
        
        _locale = (locale) ? locale : [NSLocale autoupdatingCurrentLocale];
    }
    return self;
}

#pragma mark - UIDevice

- (nonnull NSString *)deviceMake {
    return @"Apple";
}

- (nonnull NSString *)deviceModel {
    return [UIDevice currentDevice].model;
}

- (nonnull NSString *)identifierForVendor {
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

- (nonnull NSString *)deviceOS {
    return [UIDevice currentDevice].systemName;
}

- (nonnull NSString *)OSVersion {
    return [UIDevice currentDevice].systemVersion;
}

- (nullable NSString *)platformString {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    return platform;
}

- (nullable NSString *)userLangaugeCode {
    NSString * languageCode = [self.locale objectForKey:NSLocaleLanguageCode];
    if (languageCode.length == 0) {
        return nil;
    }
    return languageCode;
}

#pragma mark - IDFA

- (nonnull NSString *)advertisingIdentifier {
    return [ASIdentifierManager.sharedManager advertisingIdentifier].UUIDString;
}

- (BOOL)advertisingTrackingEnabled {
    return ASIdentifierManager.sharedManager.isAdvertisingTrackingEnabled;
}

- (NSUInteger)appTrackingTransparencyStatus {
    if (@available(iOS 14.0, *)) {
        return ATTrackingManager.trackingAuthorizationStatus;
    } else {
        return 0; //ATTrackingManagerAuthorizationStatusNotDetermined
    }
}

- (CGSize)screenSize {
    return [PBMFunctions deviceScreenSize];
}

@end

#pragma mark - UIAlertController

@implementation UIAlertController (PBMPrivate)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return false;
}

@end

