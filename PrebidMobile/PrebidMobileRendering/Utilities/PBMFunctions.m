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

#import "PBMFunctions.h"
#import "PBMFunctions+Private.h"
#import "PBMFunctions+Testing.h"

#import "PBMError.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Constants

static NSString * const PBMPlistName = @"Info";
static NSString * const PBMPlistExt = @"plist";


#pragma mark - Implementation

@implementation PBMFunctions

+ (nonnull NSString *)sdkVersion {
    NSString *version = PrebidConstants.PREBID_VERSION;
    return version ? version : @"";
}

// MARK: - SKAdNetwork

+ (nonnull NSArray<NSString *> *)supportedSKAdNetworkVersions {
    NSMutableArray<NSString *> *supportedSKAdNVersions = [[NSMutableArray<NSString*> alloc] init];
    
    if (@available(iOS 14.5, *)) {
        [supportedSKAdNVersions addObject:@"2.2"];
    }
    
    if (@available(iOS 14.6, *)) {
        [supportedSKAdNVersions addObject:@"3.0"];
    }
    
    if (@available(iOS 16.2, *)) {
        [supportedSKAdNVersions addObject:@"4.0"];
    }
    
    return supportedSKAdNVersions;
}

+ (nonnull NSDictionary<NSString *, NSString *> *)extractVideoAdParamsFromTheURLString:(NSString *)urlString forKeys:(NSArray *)keys {
    NSMutableDictionary<NSString *, NSString *> *result = [[NSMutableDictionary alloc] init];
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    if (components.host) {
        [result setObject:components.host forKey:PBM_DOMAIN_KEY];
    }
    for (NSString *key in keys) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
        NSURLQueryItem *queryItem = [[components.queryItems filteredArrayUsingPredicate:predicate] firstObject];
        if (queryItem.value) {
            [result setObject:queryItem.value forKey:key];
        }
    }
    
    return result;
}

+ (BOOL)canLoadVideoAdWithDomain:(NSString *)domain adUnitID:(NSString *)adUnitID adUnitGroupID:(NSString *)adUnitGroupID {
    if (!domain) {
        return false;
    }
    
    return (adUnitID || adUnitGroupID);
}

+ (void)checkCertificateChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    // Check if mock server host
    if (![challenge.protectionSpace.host isEqualToString:@"10.0.2.2"]) {
        // Default handling
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, NULL);
    }
    
    CFStringRef certificateHost = NULL;
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
    if (serverTrust && certificate) {
        certificateHost = SecCertificateCopySubjectSummary(certificate);
    }
    NSURLCredential *credential = [NSURLCredential credentialForTrust: challenge.protectionSpace.serverTrust];
    
    // Only allow when involving 10.0.2.2 mock server host
    if (certificateHost && [(__bridge NSString *)certificateHost isEqualToString:@"10.0.2.2"]) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
    if (certificateHost != nil) {
        CFRelease(certificateHost);
    }
}

#pragma mark - Private

#pragma mark - URLs
+ (void) attemptToOpen:(nonnull NSURL*)url {
    id<PBMUIApplicationProtocol> pbmUIApplication;
    if (self.application) {
        pbmUIApplication = self.application;
    } else {
        UIApplication* uiApplication = [UIApplication sharedApplication];
        if (!uiApplication) {
            PBMLogWarn(@"[UIApplication sharedApplication] is nil. Potentially running in Unit Test Target.");
            return;
        }
        
        //Since only one UIApplication can exist at a time it can only be "mocked" by applying a protocol
        //to it that it already conforms to.
        if (![uiApplication conformsToProtocol:@protocol(PBMUIApplicationProtocol)]) {
            PBMLogError(@"[UIApplication sharedApplication] does not conform to PBMUIApplicationProtocol.");
            return;
        }
        pbmUIApplication = (id<PBMUIApplicationProtocol>)uiApplication;
    } 
    
    [PBMFunctions attemptToOpen:url pbmUIApplication:pbmUIApplication];
}

+ (void) attemptToOpen:(nonnull NSURL*)url pbmUIApplication:(nonnull id<PBMUIApplicationProtocol>)pbmUIApplication {
    [pbmUIApplication openURL:url options:@{} completionHandler:nil];
}

#pragma mark - Time

+ (NSTimeInterval)clamp:(NSTimeInterval)value
             lowerBound:(NSTimeInterval)lowerBound
             upperBound:(NSTimeInterval)upperBound {
    NSTimeInterval max = MAX(value, lowerBound);
    return MIN(max, upperBound);
}

+ (NSInteger)clampInt:(NSInteger)value
           lowerBound:(NSInteger)lowerBound
           upperBound:(NSInteger)upperBound {
    NSInteger max = MAX(value, lowerBound);
    return MIN(max, upperBound);
}

+ (NSTimeInterval)clampAutoRefresh:(NSTimeInterval)val {
    return [PBMFunctions clamp:val
                    lowerBound:PBMAutoRefresh.AUTO_REFRESH_DELAY_MIN
                    upperBound:PBMAutoRefresh.AUTO_REFRESH_DELAY_MAX];
}

+ (dispatch_time_t)dispatchTimeAfterTimeInterval:(NSTimeInterval)timeInterval {
    return [PBMFunctions dispatchTimeAfterTimeInterval:timeInterval startTime:DISPATCH_TIME_NOW];
}

+ (dispatch_time_t)dispatchTimeAfterTimeInterval:(NSTimeInterval)timeInterval startTime:(dispatch_time_t)startTime {
    int64_t delta = timeInterval * NSEC_PER_SEC;
    return dispatch_time(startTime, delta);
}

#pragma mark - JSON

+ (nullable PBMJsonDictionary *)dictionaryFromJSONString:(nonnull NSString *)jsonString error:(NSError* _Nullable __autoreleasing * _Nullable)error {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        [PBMError createError:error description:[NSString stringWithFormat:@"Could not convert jsonString to data: %@", jsonString]];
        return nil;
    }
    
    return [PBMFunctions dictionaryFromData:jsonData error:error];
}

+ (nullable PBMJsonDictionary *)dictionaryFromData:(nonnull NSData *)jsonData error:(NSError* _Nullable __autoreleasing * _Nullable)error {
    if (!jsonData) {
        [PBMError createError:error description:[NSString stringWithFormat:@"Invalid JSON data: %@", jsonData]];
        return nil;
    }
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:error];
    if (!jsonObject) {
        [PBMError createError:error description:[NSString stringWithFormat:@"Could not convert json data to jsonObject: %@", jsonData]];
        return nil;
    }
    
    if (![jsonObject isKindOfClass:[PBMJsonDictionary class]]) {
        [PBMError createError:error description:[NSString stringWithFormat:@"Could not cast jsonObject to JsonDictionary: %@", jsonData]];
        return nil;
    }
    
    return (PBMJsonDictionary *)jsonObject;
}

+ (nullable NSString *)toStringJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary error:(NSError* _Nullable __autoreleasing * _Nullable)error {
    if (![NSJSONSerialization isValidJSONObject:jsonDictionary]) {
        [PBMError createError:error description:[NSString stringWithFormat:@"Not valid JSON object: %@", jsonDictionary]];
        return nil;
    }
    
    NSData *data = nil;
    if (@available(iOS 11.0, *)) {
        data = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingSortedKeys error:error];
    } else {
        data = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:error];
    }
    
    if (!data) {
        [PBMError createError:error description:[NSString stringWithFormat:@"Could not convert JsonDictionary: %@", jsonDictionary]];
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!jsonString) {
        [PBMError createError:error description:[NSString stringWithFormat:@"Could not convert JsonDictionary: %@", jsonDictionary]];
        return nil;
    }
    
    return [jsonString stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

+ (nullable NSArray<PBMJsonDictionary *> *)dictionariesForPassthrough:(id)passthrough {
    if ([passthrough isKindOfClass:[NSArray<PBMJsonDictionary*> class]]) {
        NSArray<PBMJsonDictionary *> *response = passthrough;
        return response;
    } else if ([passthrough isKindOfClass:[PBMJsonDictionary class]]) {
        NSDictionary *response = passthrough;
        return @[response];
    } else {
        return nil;
    }
}

#pragma mark - SDK Info

+ (nonnull NSBundle *)bundleForSDK {
    //bundleForClass takes a class in the bundle as an argument.
    //We pass it PBMError.self as that class to guarantee that we're
    //getting the SDK bundle.

    NSBundle * mainBundle = [NSBundle bundleForClass:[self class]];
    NSString * pathToResourcesBundle = [mainBundle pathForResource:@"PrebidSDKCoreResources" ofType:@"bundle"];
    if (pathToResourcesBundle) {
        return [NSBundle bundleWithPath:pathToResourcesBundle];
    }
    return mainBundle;
}

+ (nullable NSString *)infoPlistValueFor:(nonnull NSString *)key {
    if (!key) {
        return nil;
    }
    
    //Note: If PrebidMobile will be delivered via source files the bundle and plist will be owned by the client app
    NSBundle *bundle = [PBMFunctions bundleForSDK];
    NSString* ret = [bundle objectForInfoDictionaryKey:key];
    
    if ([ret isKindOfClass:[NSString class]]) {
        return ret;
    }
    
    return nil;
}

#pragma mark - UI

+ (CGFloat)statusBarHeight {
    CGFloat ret = 0.0;
    
    UIApplication* application = [UIApplication sharedApplication];
    if ([application conformsToProtocol:@protocol(PBMUIApplicationProtocol)]) {
        id<PBMUIApplicationProtocol> pbmApplication = (id<PBMUIApplicationProtocol>)application;
        ret = [PBMFunctions statusBarHeightForApplication:pbmApplication];
    }
    
    return ret;
}

+ (CGFloat)statusBarHeightForApplication:(nonnull id<PBMUIApplicationProtocol>)application {
    if (!application || application.isStatusBarHidden) {
        return 0.0;
    } else if (UIInterfaceOrientationIsPortrait(application.statusBarOrientation)) {
        return application.statusBarFrame.size.height;
    }
    
    return application.statusBarFrame.size.width;
}

+ (UIEdgeInsets)safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return UIApplication.sharedApplication.keyWindow.safeAreaInsets;
    } else {
        return (UIEdgeInsets){.left = 0, .top = 0, .right = 0, .bottom = 0};
    }
}

#pragma mark - Device Info

+ (CGSize)deviceScreenSize {
    return [[UIScreen mainScreen] bounds].size;
}

+ (CGSize)deviceMaxSize {
    CGSize screenSize = [PBMFunctions deviceScreenSize];
    UIEdgeInsets saInsets = [PBMFunctions safeAreaInsets];
    return CGSizeMake(screenSize.width - saInsets.left - saInsets.right,
                      screenSize.height - [PBMFunctions statusBarHeight] - saInsets.top - saInsets.bottom);
}

+ (BOOL)isSimulator {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

@end
