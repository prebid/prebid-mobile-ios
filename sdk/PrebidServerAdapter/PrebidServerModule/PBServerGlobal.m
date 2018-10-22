/*   Copyright 2017 Prebid.org, Inc.
 
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

#import "PBServerGlobal.h"
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

static NSString *const kIFASentinelValue = @"00000000-0000-0000-0000-000000000000";

NSString *PBSUserAgent() {
    static NSString *userAgent = nil;
    if (userAgent == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWebView *webview = [[UIWebView alloc] init];
            userAgent = [[webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"] copy];
            webview.delegate = nil;
            [webview stopLoading];
        });
    }
    return userAgent;
}

NSString *PBSDeviceModel() {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return @(systemInfo.machine);
}


NSString *PBSUDID() {
    static NSString *udidComponent = @"";
    if ([udidComponent isEqualToString:@""]) {
        NSString *advertisingIdentifier = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
        if (advertisingIdentifier && ![advertisingIdentifier isEqualToString:kIFASentinelValue]) {
            udidComponent = advertisingIdentifier;
        }
    }
    return udidComponent;
}

BOOL PBSAdvertisingTrackingEnabled() {
    // If a user does turn this off, use the unique identifier *only* for the
    // following:
    // - Frequency capping
    // - Conversion events
    // - Estimating number of unique users
    // - Security and fraud detection
    // - Debugging
    return [ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled;
}

NSArray *PBSConvertToNSArray(id value) {
    if ([value isKindOfClass:[NSArray class]])
        return value;
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value array];
    }
    return nil;
}

NSString *PBSConvertToNSString(id value) {
    if ([value isKindOfClass:[NSString class]])
        return value;
    if ([value respondsToSelector:@selector(stringValue)]) {
        return [value stringValue];
    }
    return nil;
}

@implementation PBServerGlobal

+ (void)load {
    PBSUserAgent();
}

@end
