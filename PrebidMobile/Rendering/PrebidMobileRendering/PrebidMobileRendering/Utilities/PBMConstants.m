//
//  PBMConstants.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMConstants.h"

#pragma mark - Keys

NSString * const PBM_DOMAIN_KEY                          = @"domain";
NSString * const PBM_TRANSACTION_STATE_KEY               = @"ts";
NSString * const PBM_TRACKING_URL_TEMPLATE               = @"record_tmpl";
NSString * const PBM_ORIGINAL_ADUNIT_KEY                 = @"OriginalAdUnitID";
NSString * const PBM_MOPUB_INITIALIZATION_OPTIONS_KEY    = @"prebid_mobile_sdk_rendering_initialization_options";
NSString * const PBM_PRECACHE_CONFIGURATION_KEY          = @"precache_configuration";

#pragma mark - PBMAccesibility

@implementation PBMAccesibility

+ (NSString *)CloseButtonIdentifier {
    return @"PBMCloseButton";
}

+ (NSString *)CloseButtonLabel {
    return @"PBMCloseButton";
}


+ (NSString *)CloseButtonClickThroughBrowserIdentifier {
    return @"PBMCloseButtonClickThroughBrowser";
}

+ (NSString *)CloseButtonClickThroughBrowserLabel {
    return @"PBMCloseButtonClickThroughBrowser";
}


+ (NSString *)WebViewLabel {
    return @"PBMWebView";
}

+ (NSString *)VideoAdView {
    return @"PBMVideoAdView";
}

+ (NSString *)BannerView {
    return @"PrebidBannerView";
}

@end


//MARK: MRAID
PBMMRAIDState const PBMMRAIDStateNotEnabled = @"not_enabled";
PBMMRAIDState const PBMMRAIDStateDefault = @"default";
PBMMRAIDState const PBMMRAIDStateExpanded = @"expanded";
PBMMRAIDState const PBMMRAIDStateHidden = @"hidden";
PBMMRAIDState const PBMMRAIDStateLoading = @"loading";
PBMMRAIDState const PBMMRAIDStateResized = @"resized";

//MARK: Tracking Supression Detection Strings
PBMTrackingPattern const PBMTrackingPatternRI = @"/ma/1.0/ri";
PBMTrackingPattern const PBMTrackingPatternRC = @"/ma/1.0/rc";
PBMTrackingPattern const PBMTrackingPatternRDF = @"/ma/1.0/rdf";
PBMTrackingPattern const PBMTrackingPatternRR = @"/ma/1.0/rr";
PBMTrackingPattern const PBMTrackingPatternBO = @"/ma/1.0/bo";

//MARK: Query String Parameters
PBMParameterKeys const PBMParameterKeysAPP_STORE_URL = @"url";
PBMParameterKeys const PBMParameterKeysOPEN_RTB = @"openrtb";


#pragma mark - PBMLocationParamKeys

@implementation PBMLocationParamKeys

+(NSString *)Latitude {
    return @"lat";
}

+(NSString *)Longitude {
    return @"lon";
}

+(NSString *)Country {
    return @"cnt";
}

+(NSString *)City {
    return @"cty";
}

+(NSString *)State {
    return @"stt";
}

+(NSString *)Zip {
    return @"zip";
}

+(NSString *)LocationSource {
    return @"lt";
}

@end


#pragma mark - PBMParseKey

@implementation PBMParseKey

+(NSString *)ADUNIT {
    return @"adUnit";
}

+(NSString *)HEIGHT {
    return @"height";
}

+(NSString *)WIDTH {
    return @"width";
}

+(NSString *)HTML {
    return @"html";
}

+(NSString *)IMAGE {
    return @"image";
}

+(NSString *)NETWORK_UID {
    return @"network_uid";
}

+(NSString *)REVENUE {
    return @"revenue";
}

+(NSString *)SSM_TYPE {
    return @"apihtml";
}

@end


#pragma mark - PBMPBMAutoRefresh

@implementation PBMAutoRefresh

+(NSTimeInterval)AUTO_REFRESH_DELAY_DEFAULT {
    return 60;
}

+(NSTimeInterval)AUTO_REFRESH_DELAY_MIN {
    return 15;
}

+(NSTimeInterval)AUTO_REFRESH_DELAY_MAX {
    return 125;
}

@end


#pragma mark - PBMTimeInterval

@implementation PBMTimeInterval

+ (NSTimeInterval)VAST_LOADER_TIMEOUT {
    return 3;
}

+ (NSTimeInterval)AD_CLICKED_ALLOWED_INTERVAL {
    return 5;
}

+ (NSTimeInterval)CONNECTION_TIMEOUT_DEFAULT {
    return 3;
}

+ (NSTimeInterval)CLOSE_DELAY_MIN {
    return 2;
}

+ (NSTimeInterval)CLOSE_DELAY_MAX {
    return 30;
}

+ (NSTimeInterval)FIRE_AND_FORGET_TIMEOUT {
    return 3;
}

@end


#pragma mark - PBMTimeScale

@implementation PBMTimeScale

+(NSInteger)VIDEO_TIMESCALE {
    return 1000;
}

@end


#pragma mark - PBMGeoLocationConstants

@implementation PBMGeoLocationConstants

+(double)DISTANCE_FILTER {
    return 50.0;
}

@end


#pragma mark - PBMConstants

@implementation PBMConstants

//These MIME Types are supported for video playback by the SDK.
+(NSArray<NSString *> *)supportedVideoMimeTypes {
    static NSArray *_supportedVideoMimeTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _supportedVideoMimeTypes = @[
            @"video/mp4",
            @"video/quicktime",
            @"video/x-m4v",
            @"video/3gpp",
            @"video/3gpp2",
        ];
    });
    return _supportedVideoMimeTypes;
}

//This is an exhaustive list of URL schemes that should be handled by the OS to launch iTunes or the App Store.
+(NSArray<NSString *> *)urlSchemesForAppStoreAndITunes {
    static NSArray *_urlSchemesForAppStoreAndITunes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _urlSchemesForAppStoreAndITunes = @[
            @"itms",         //Launches iTunes Store
            @"itmss",        //As itms, but encrypted
            @"itms-apps",    //Launches App Store
            @"itms-appss"    //As itms-apps, but encrypted
        ];
    });
    return _urlSchemesForAppStoreAndITunes;
}

//This is a non-exhaustive list of URL schemes representing apps and services that are not supported by the simulator.
+(NSArray<NSString *> *)urlSchemesNotSupportedOnSimulator {
    static NSArray *_urlSchemesNotSupportedOnSimulator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _urlSchemesNotSupportedOnSimulator = @[
            @"tel",          //Launches iTunes Store
            @"itms",         //Launches iTunes Store
            @"itmss",        //As itms, but encrypted
            @"itms-apps",    //Launches App Store
            @"itms-appss"    //As itms-apps, but encrypted
        ];
    });
    return _urlSchemesNotSupportedOnSimulator;
}

//URL Schemes not supported by the clickthrough browser
+(NSArray<NSString *> *)urlSchemesNotSupportedOnClickthroughBrowser {
    static NSArray *_urlSchemesNotSupportedOnClickthroughBrowser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _urlSchemesNotSupportedOnClickthroughBrowser = @[
            @"sms",          //Launches Messages App
            @"tel",          //Launches Phone app
            @"itms",         //Launches iTunes Store
            @"itmss",        //As itms, but encrypted
            @"itms-apps",    //Launches App Store
            @"itms-appss"    //As itms-apps, but encrypted
        ];
    });
    return _urlSchemesNotSupportedOnClickthroughBrowser;
}

@end
