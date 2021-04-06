//
//  BasicParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXATargeting+Private.h"
#import "OXMConstants.h"
#import "OXMMacros.h"
#import "OXMORTB.h"

#import "OXMBasicParameterBuilder.h"

#pragma mark - Internal Extension

@interface OXMBasicParameterBuilder ()

// Note: properties below are marked with 'readwrite' for UnitTests to be able to write 'nil' into them.
// TODO: Prove that 'init' arguments are never nil; convert to 'readonly'; remove redundant checks and tests.

@property (nonatomic, strong, readwrite) OXMAdConfiguration *adConfiguration;
@property (nonatomic, strong, readwrite) OXASDKConfiguration *sdkConfiguration;
@property (nonatomic, strong, readwrite) OXATargeting *targeting;
@property (nonatomic, copy, readwrite) NSString *sdkVersion;

@end

#pragma mark - Implementation

@implementation OXMBasicParameterBuilder

#pragma mark - Properties

+ (NSString *)platformKey {
    return @"sp";
}

+ (NSString *)platformValue {
    return @"iOS";
}

+ (NSString *)allowRedirectsKey {
    return @"dr";
}

+ (NSString *)allowRedirectsVal {
    return @"true";
}

+ (NSString *)sdkVersionKey {
    return @"sv";
}

+ (NSString *)urlKey {
    return OXMParameterKeysAPP_STORE_URL;
}

+ (NSString*)rewardedVideoKey {
    return @"vrw";
}

+ (NSString*)rewardedVideoValue {
    return @"1";
}

#pragma mark - Initialization

- (instancetype)initWithAdConfiguration:(OXMAdConfiguration *)adConfiguration
                       sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration
                             sdkVersion:(NSString *)sdkVersion
                              targeting:(OXATargeting *)targeting
{
    if (!(self = [super init])) {
        return nil;
    }
    OXMAssert(adConfiguration && sdkConfiguration && sdkVersion && targeting);
    
    _adConfiguration = adConfiguration;
    _sdkConfiguration = sdkConfiguration;
    _sdkVersion = sdkVersion;
    _targeting = targeting;
    
    return self;
}

#pragma mark - Methods

- (void)buildBidRequest:(OXMORTBBidRequest *)bidRequest {
    if (!(self.adConfiguration && self.sdkConfiguration && self.sdkVersion)) {
        OXMLogError(@"Invalid properties");
        return;
    }

    //Add an impression if none exist
    if ([bidRequest.imp count] == 0) {
        bidRequest.imp = @[[[OXMORTBImp alloc] init]];
    }
    
    for (OXMORTBImp *rtbImp in bidRequest.imp) {
        rtbImp.displaymanagerver = self.sdkVersion;
        rtbImp.instl = @(self.adConfiguration.presentAsInterstitial ? 1 : 0);
        
        //set secure=1 for https or secure=0 for http
        rtbImp.secure = @1;
        
        rtbImp.clickbrowser = @(self.sdkConfiguration.useExternalClickthroughBrowser ? 1 : 0);
    }
    
    bidRequest.regs.coppa = self.targeting.coppa;
    
    [self appendFormatSpecificParametersForRequest:bidRequest];
}

- (void)appendFormatSpecificParametersForRequest:(OXMORTBBidRequest *)bidRequest {
    switch (self.adConfiguration.adFormat) {
        case OXMAdFormatDisplay:
            [self appendDisplayParametersForRequest:bidRequest];
            break;
            
        case OXMAdFormatVideo:
            [self appendVideoParametersForRequest:bidRequest];
            break;
            
        case OXMAdFormatNative: {
            [self appendNativeParametersForRequest:bidRequest];
            break;
        }
    }
}

- (void)appendDisplayParametersForRequest:(OXMORTBBidRequest *)bidRequest {
    //Ensure there's at least 1 banner
    BOOL hasBanner = NO;
    for (OXMORTBImp *imp in bidRequest.imp) {
        if (imp.banner) {
            hasBanner = YES;
            break;
        }
    }
    
    if (!hasBanner) {
        [bidRequest.imp firstObject].banner = [[OXMORTBBanner alloc] init];
    }
}

- (void)appendVideoParametersForRequest:(OXMORTBBidRequest *)bidRequest {

    OXMORTBVideo * const videoObj = [[OXMORTBVideo alloc] init];
    
    if (self.adConfiguration.videoPlacementType != OXAVideoPlacementType_Undefined) {
        videoObj.placement = @(self.adConfiguration.videoPlacementType);
    }
    [bidRequest.imp firstObject].video = videoObj;
}

- (void)appendNativeParametersForRequest:(OXMORTBBidRequest *)bidRequest {
    [bidRequest.imp firstObject].native = [[OXMORTBNative alloc] init];
}

@end
