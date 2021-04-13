//
//  OXMDeviceInfoParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <AppTrackingTransparency/AppTrackingTransparency.h>

#import "OXMDeviceInfoParameterBuilder.h"
#import "OXMORTB.h"
#import "OXMORTBAbstract+Protected.h"
#import "OXMDeviceAccessManager.h"
#import "OXMMacros.h"

#pragma mark - Internal Extension

@interface OXMDeviceInfoParameterBuilder()

@property (nonatomic, strong) OXMDeviceAccessManager *deviceAccessManager;

@end

#pragma mark - Implementation

@implementation OXMDeviceInfoParameterBuilder

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

- (nonnull instancetype)initWithDeviceAccessManager:(nonnull OXMDeviceAccessManager *)deviceAccessManager {
    self = [super init];
    if (self) {
        OXMAssert(deviceAccessManager);
        
        self.deviceAccessManager = deviceAccessManager;
    }
    
    return self;
}

#pragma mark - OXMParameterBuilder

- (void)buildBidRequest:(OXMORTBBidRequest *)bidRequest {
    if (!(self.deviceAccessManager && bidRequest)) {
        OXMLogError(@"Invalid properties");
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
    NSString *ifa = self.deviceAccessManager.advertisingIdentifier;
    
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
