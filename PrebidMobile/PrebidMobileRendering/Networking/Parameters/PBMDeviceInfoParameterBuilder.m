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

#import <AppTrackingTransparency/AppTrackingTransparency.h>

#import "PBMDeviceInfoParameterBuilder.h"
#import "PBMORTB.h"
#import "PBMORTBAbstract+Protected.h"
#import "PBMDeviceAccessManager.h"
#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

#pragma mark - Internal Extension

@interface PBMDeviceInfoParameterBuilder()

@property (nonatomic, strong) PBMDeviceAccessManager *deviceAccessManager;

@end

#pragma mark - Implementation

@implementation PBMDeviceInfoParameterBuilder

#pragma mark - Properties

+ (NSString *)ifaKey {
    return @"ifa";
}

+ (NSString *)lmtKey {
    return @"lmt";
}

+ (NSString *)ifvKey {
    return @"ifv";
}

+ (NSString *)attsKey {
    return @"atts";
}

#pragma mark - Initialization

- (nonnull instancetype)initWithDeviceAccessManager:(nonnull PBMDeviceAccessManager *)deviceAccessManager {
    self = [super init];
    if (self) {
        PBMAssert(deviceAccessManager);
        
        self.deviceAccessManager = deviceAccessManager;
    }
    
    return self;
}

#pragma mark - PBMParameterBuilder

- (void)buildBidRequest:(PBMORTBBidRequest *)bidRequest {
    if (!(self.deviceAccessManager && bidRequest)) {
        PBMLogError(@"Invalid properties");
        return;
    }
    
    CGSize screenSize = self.deviceAccessManager.screenSize;
    
    bidRequest.device.w = @(screenSize.width);
    bidRequest.device.h = @(screenSize.height);

    // The OpenRTB `lmt` property is the inverse of Apple's `ASIdentifierManager` API.
    // OpenRTB spec defines `lmt` as:
    //     “Limit Ad Tracking” signal commercially endorsed (e.g., iOS, Android), where 0 = tracking
    //     is unrestricted, 1 = tracking must be limited per commercial guidelines.
    NSNumber *lmt = @(!self.deviceAccessManager.advertisingTrackingEnabled);
    
    NSString *ifa = [Targeting.shared isAllowedAccessDeviceData] ? self.deviceAccessManager.advertisingIdentifier : nil;
    
    bidRequest.device.lmt = lmt;
    bidRequest.device.ifa = ifa;
    
    
    //Only passed when IDFA (BidRequest.device.ifa) is unavailable or all zeros.
    if (!ifa || [ifa isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        bidRequest.device.extAtts.ifv = self.deviceAccessManager.identifierForVendor;
    }
    
    //https://github.com/InteractiveAdvertisingBureau/openrtb/blob/master/extensions/community_extensions/skadnetwork.md#device-extension
    if (@available(iOS 14.0, *)) {
        NSNumber *atts = nil;
        atts = @(self.deviceAccessManager.appTrackingTransparencyStatus);
        bidRequest.device.extAtts.atts = atts;
        lmt = atts.intValue == ATTrackingManagerAuthorizationStatusAuthorized ? @(0) : @(1);
        bidRequest.device.lmt = lmt;
    }

    bidRequest.device.make = self.deviceAccessManager.deviceMake;
    bidRequest.device.model = self.deviceAccessManager.deviceModel;
    bidRequest.device.os = self.deviceAccessManager.deviceOS;
    bidRequest.device.osv = self.deviceAccessManager.OSVersion;
    bidRequest.device.hwv = self.deviceAccessManager.platformString;
    bidRequest.device.language = self.deviceAccessManager.userLangaugeCode;
}

@end
