//
//  OXMFunctions.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMFunctions.h"
#import "OXMFunctions+Private.h"
#import "OXMFunctions+Testing.h"

#import "OXMConstants.h"
#import "OXMError.h"
#import "OXMServerResponse.h"
#import "OXMLog.h"

#pragma mark - Constants

static NSString * const OXMPlistName = @"Info";
static NSString * const OXMPlistExt = @"plist";


#pragma mark - Implementation

@implementation OXMFunctions

+ (nonnull NSString *)sdkVersion {
    NSString *version = [OXMFunctions infoPlistValueFor:@"CFBundleShortVersionString"];
    return version ? version : @"";
}

+ (NSString *)omidVersion {
    // FIXME: review the version on the next certification with IAB
    return @"5.0";
}


+ (nonnull NSDictionary<NSString *, NSString *> *)extractVideoAdParamsFromTheURLString:(NSString *)urlString forKeys:(NSArray *)keys {
    NSMutableDictionary<NSString *, NSString *> *result = [[NSMutableDictionary alloc] init];
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    if (components.host) {
        [result setObject:components.host forKey:OXM_DOMAIN_KEY];
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
    id<OXMUIApplicationProtocol> oxmUIApplication;
    if (self.application) {
        oxmUIApplication = self.application;
    } else {
        UIApplication* uiApplication = [UIApplication sharedApplication];
        if (!uiApplication) {
            OXMLogWarn(@"[UIApplication sharedApplication] is nil. Potentially running in Unit Test Target.");
            return;
        }
        
        //Since only one UIApplication can exist at a time it can only be "mocked" by applying a protocol
        //to it that it already conforms to.
        if (![uiApplication conformsToProtocol:@protocol(OXMUIApplicationProtocol)]) {
            OXMLogError(@"[UIApplication sharedApplication] does not conform to OXMUIApplicationProtocol.");
            return;
        }
        oxmUIApplication = (id<OXMUIApplicationProtocol>)uiApplication;
    } 
    
    [OXMFunctions attemptToOpen:url oxmUIApplication:oxmUIApplication];
}

+ (void) attemptToOpen:(nonnull NSURL*)url oxmUIApplication:(nonnull id<OXMUIApplicationProtocol>)oxmUIApplication {
    
    //iOS 10 makes available a new version of openURL and deprecates the old one.
    if (@available(iOS 10, *)) {
        [oxmUIApplication openURL:url options:@{} completionHandler:nil];
    } else {
        [oxmUIApplication openURL:url];
    }
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
    return [OXMFunctions clamp:val
                    lowerBound:OXMAutoRefresh.AUTO_REFRESH_DELAY_MIN
                    upperBound:OXMAutoRefresh.AUTO_REFRESH_DELAY_MAX];
}

+ (dispatch_time_t)dispatchTimeAfterTimeInterval:(NSTimeInterval)timeInterval {
    return [OXMFunctions dispatchTimeAfterTimeInterval:timeInterval startTime:DISPATCH_TIME_NOW];
}

+ (dispatch_time_t)dispatchTimeAfterTimeInterval:(NSTimeInterval)timeInterval startTime:(dispatch_time_t)startTime {
    int64_t delta = timeInterval * NSEC_PER_SEC;
    return dispatch_time(startTime, delta);
}

#pragma mark - JSON

+ (nullable OXMJsonDictionary *)dictionaryFromJSONString:(nonnull NSString *)jsonString error:(NSError* _Nullable __autoreleasing * _Nullable)error {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        [OXMError createError:error description:[NSString stringWithFormat:@"Could not convert jsonString to data: %@", jsonString]];
        return nil;
    }
    
    return [OXMFunctions dictionaryFromData:jsonData error:error];
}

+ (nullable OXMJsonDictionary *)dictionaryFromData:(nonnull NSData *)jsonData error:(NSError* _Nullable __autoreleasing * _Nullable)error {
    if (!jsonData) {
        [OXMError createError:error description:[NSString stringWithFormat:@"Invalid JSON data: %@", jsonData]];
        return nil;
    }
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:error];
    if (!jsonObject) {
        [OXMError createError:error description:[NSString stringWithFormat:@"Could not convert json data to jsonObject: %@", jsonData]];
        return nil;
    }
    
    if (![jsonObject isKindOfClass:[OXMJsonDictionary class]]) {
        [OXMError createError:error description:[NSString stringWithFormat:@"Could not cast jsonObject to JsonDictionary: %@", jsonData]];
        return nil;
    }
    
    return (OXMJsonDictionary *)jsonObject;
}

+ (nullable NSString *)toStringJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary error:(NSError* _Nullable __autoreleasing * _Nullable)error {
    if (![NSJSONSerialization isValidJSONObject:jsonDictionary]) {
        [OXMError createError:error description:[NSString stringWithFormat:@"Not valid JSON object: %@", jsonDictionary]];
        return nil;
    }
    
    NSData *data = nil;
    if (@available(iOS 11.0, *)) {
        data = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingSortedKeys error:error];
    } else {
        data = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:error];
    }
    
    if (!data) {
        [OXMError createError:error description:[NSString stringWithFormat:@"Could not convert JsonDictionary: %@", jsonDictionary]];
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!jsonString) {
        [OXMError createError:error description:[NSString stringWithFormat:@"Could not convert JsonDictionary: %@", jsonDictionary]];
        return nil;
    }
    
    return [jsonString stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

#pragma mark - SDK Info

+ (nonnull NSBundle *)bundleForSDK {
    //bundleForClass takes a class in the bundle as an argument.
    //We pass it OXMError.self as that class to guarantee that we're
    //getting the SDK bundle.

    NSBundle * mainBundle = [NSBundle bundleForClass:[self class]];
    NSString * pathToResourcesBundle = [mainBundle pathForResource:@"OpenXSDKCoreResources" ofType:@"bundle"];
    if (pathToResourcesBundle) {
        return [NSBundle bundleWithPath:pathToResourcesBundle];
    }
    return mainBundle;
}

+ (nullable NSString *)infoPlistValueFor:(nonnull NSString *)key {
    if (!key) {
        return nil;
    }
    
    //Note: If OpenX will be delivered via source files the bundle and plist will be owned by the client app
    NSBundle *bundle = [OXMFunctions bundleForSDK];
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
    if ([application conformsToProtocol:@protocol(OXMUIApplicationProtocol)]) {
        id<OXMUIApplicationProtocol> oxmApplication = (id<OXMUIApplicationProtocol>)application;
        ret = [OXMFunctions statusBarHeightForApplication:oxmApplication];
    }
    
    return ret;
}

+ (CGFloat)statusBarHeightForApplication:(nonnull id<OXMUIApplicationProtocol>)application {
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
    CGSize screenSize = [OXMFunctions deviceScreenSize];
    UIEdgeInsets saInsets = [OXMFunctions safeAreaInsets];
    return CGSizeMake(screenSize.width - saInsets.left - saInsets.right,
                      screenSize.height - [OXMFunctions statusBarHeight] - saInsets.top - saInsets.bottom);
}

+ (BOOL)isSimulator {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

@end
