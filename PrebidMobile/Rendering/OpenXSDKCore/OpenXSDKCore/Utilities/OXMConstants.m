//
//  OXMConstants.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMConstants.h"

#pragma mark - Keys

NSString * const OXM_DOMAIN_KEY                          = @"domain";
NSString * const OXM_TRANSACTION_STATE_KEY               = @"ts";
NSString * const OXM_TRACKING_URL_TEMPLATE               = @"record_tmpl";
NSString * const OXM_ORIGINAL_ADUNIT_KEY                 = @"OriginalAdUnitID";
NSString * const OXM_MOPUB_INITIALIZATION_OPTIONS_KEY    = @"openx_sdk_initialization_options";
NSString * const OXM_PRECACHE_CONFIGURATION_KEY          = @"precache_configuration";

#pragma mark - OXMAccesibility

@implementation OXMAccesibility

+ (NSString *)CloseButtonIdentifier {
    return @"OXMCloseButton";
}

+ (NSString *)CloseButtonLabel {
    return @"OXMCloseButton";
}


+ (NSString *)CloseButtonClickThroughBrowserIdentifier {
    return @"OXMCloseButtonClickThroughBrowser";
}

+ (NSString *)CloseButtonClickThroughBrowserLabel {
    return @"OXMCloseButtonClickThroughBrowser";
}


+ (NSString *)WebViewLabel {
    return @"OXMWebView";
}

+ (NSString *) VideoAdView {
    return @"OXMVideoAdView";
}

@end


//MARK: MRAID
OXMMRAIDState const OXMMRAIDStateNotEnabled = @"not_enabled";
OXMMRAIDState const OXMMRAIDStateDefault = @"default";
OXMMRAIDState const OXMMRAIDStateExpanded = @"expanded";
OXMMRAIDState const OXMMRAIDStateHidden = @"hidden";
OXMMRAIDState const OXMMRAIDStateLoading = @"loading";
OXMMRAIDState const OXMMRAIDStateResized = @"resized";

//MARK: Tracking Supression Detection Strings
OXMTrackingPattern const OXMTrackingPatternRI = @"/ma/1.0/ri";
OXMTrackingPattern const OXMTrackingPatternRC = @"/ma/1.0/rc";
OXMTrackingPattern const OXMTrackingPatternRDF = @"/ma/1.0/rdf";
OXMTrackingPattern const OXMTrackingPatternRR = @"/ma/1.0/rr";
OXMTrackingPattern const OXMTrackingPatternBO = @"/ma/1.0/bo";

//MARK: Query String Parameters
OXMParameterKeys const OXMParameterKeysAPP_STORE_URL = @"url";
OXMParameterKeys const OXMParameterKeysOPEN_RTB = @"openrtb";


#pragma mark - OXMLocationParamKeys

@implementation OXMLocationParamKeys

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


#pragma mark - OXMParseKey

@implementation OXMParseKey

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


#pragma mark - OXMOXMAutoRefresh

@implementation OXMAutoRefresh

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


#pragma mark - OXMTimeInterval

@implementation OXMTimeInterval

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


#pragma mark - OXMTimeScale

@implementation OXMTimeScale

+(NSInteger)VIDEO_TIMESCALE {
    return 1000;
}

@end


#pragma mark - OXMGeoLocationConstants

@implementation OXMGeoLocationConstants

+(double)DISTANCE_FILTER {
    return 50.0;
}

@end


#pragma mark - OXMConstants

@implementation OXMConstants

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
