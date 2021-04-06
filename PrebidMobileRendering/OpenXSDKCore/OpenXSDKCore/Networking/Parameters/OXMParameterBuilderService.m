//
//  OXMParameterBuilderService.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "OXAAgeUtils.h"
#import "OXATargeting.h"
#import "OXATargeting+Private.h"
#import "OXMAdConfiguration.h"
#import "OXMAppInfoParameterBuilder.h"
#import "OXMBasicParameterBuilder.h"
#import "OXMDeviceAccessManager.h"
#import "OXMDeviceInfoParameterBuilder.h"
#import "OXMFunctions.h"
#import "OXMGeoLocationParameterBuilder.h"
#import "OXMLocationManager.h"
#import "OXMLog.h"
#import "OXMNetworkParameterBuilder.h"
#import "OXMORTBParameterBuilder.h"
#import "OXMParameterBuilderProtocol.h"
#import "OXASDKConfiguration.h"
#import "OXMSupportedProtocolsParameterBuilder.h"
#import "OXASKAdNetworksParameterBuilder.h"
#import "OXMUserConsentDataManager.h"
#import "OXMUserConsentParameterBuilder.h"
#import "OXMORTB.h"

#import "OXMParameterBuilderService.h"

@implementation OXMParameterBuilderService

+ (nonnull NSDictionary<NSString* , NSString *> *)buildParamsDictWithAdConfiguration:(nonnull OXMAdConfiguration *)adConfiguration {
    return [self buildParamsDictWithAdConfiguration:adConfiguration extraParameterBuilders:nil];
}

+ (nonnull NSDictionary<NSString* , NSString *> *)buildParamsDictWithAdConfiguration:(nonnull OXMAdConfiguration *)adConfiguration extraParameterBuilders:(nullable NSArray<id<OXMParameterBuilder> > *)extraParameterBuilders {
    OXATargeting * const targetingClone = [[OXATargeting shared] copy];
    targetingClone.disableLockUsage = YES;
    return [self buildParamsDictWithAdConfiguration:adConfiguration
                                             bundle:NSBundle.mainBundle
                                 oxmLocationManager:OXMLocationManager.singleton
                             oxmDeviceAccessManager:[[OXMDeviceAccessManager alloc] initWithRootViewController: nil]
                             ctTelephonyNetworkInfo:[CTTelephonyNetworkInfo new]
                                       reachability:[OXMReachability reachabilityForInternetConnection]
                                   sdkConfiguration:OXASDKConfiguration.singleton
                                         sdkVersion:[OXMFunctions sdkVersion]
                              oxmUserConsentManager:[OXMUserConsentDataManager singleton]
                                          targeting:targetingClone
                             extraParameterBuilders:extraParameterBuilders];
}

// Input parameters validation: certain parameter will be validated in particular builder.
// In such case, even if some parameter is invalid all other builders will work.
+ (nonnull NSDictionary<NSString* , NSString *> *)buildParamsDictWithAdConfiguration:(nonnull OXMAdConfiguration *)adConfiguration
                                                                              bundle:(nonnull id<OXMBundleProtocol>)bundle
                                                                  oxmLocationManager:(nonnull OXMLocationManager *)oxmLocationManager
                                                              oxmDeviceAccessManager:(nonnull OXMDeviceAccessManager *)oxmDeviceAccessManager
                                                              ctTelephonyNetworkInfo:(nonnull CTTelephonyNetworkInfo *)ctTelephonyNetworkInfo
                                                                        reachability:(nonnull OXMReachability *)reachability
                                                                    sdkConfiguration:(nonnull OXASDKConfiguration *)sdkConfiguration
                                                                          sdkVersion:(nonnull NSString *)sdkVersion
                                                               oxmUserConsentManager:(nonnull OXMUserConsentDataManager *) oxmUserConsentManager
                                                                           targeting:(nonnull OXATargeting *)targeting
                                                              extraParameterBuilders:(nullable NSArray<id<OXMParameterBuilder> > *)extraParameterBuilders{
  
    OXMORTBBidRequest *bidRequest = [OXMParameterBuilderService createORTBBidRequestWithTargeting:targeting];
    
    NSMutableArray<id<OXMParameterBuilder> > * const parameterBuilders = [[NSMutableArray alloc] init];
    [parameterBuilders addObjectsFromArray:@[
        [[OXMBasicParameterBuilder alloc] initWithAdConfiguration:adConfiguration
                                                 sdkConfiguration:sdkConfiguration
                                                       sdkVersion:sdkVersion
                                                        targeting:targeting],
        [[OXMGeoLocationParameterBuilder alloc] initWithLocationManager:oxmLocationManager],
        [[OXMAppInfoParameterBuilder alloc] initWithBundle:bundle targeting:targeting],
        [[OXMDeviceInfoParameterBuilder alloc] initWithDeviceAccessManager:oxmDeviceAccessManager],
        [[OXMNetworkParameterBuilder alloc] initWithCtTelephonyNetworkInfo:ctTelephonyNetworkInfo reachability:reachability],
        [[OXMSupportedProtocolsParameterBuilder alloc] initWithSDKConfiguration:sdkConfiguration],
        [[OXMUserConsentParameterBuilder alloc] initWithUserConsentManager:oxmUserConsentManager],
        [[OXASKAdNetworksParameterBuilder alloc] initWithBundle:bundle targeting:targeting],
    ]];
    
    if (extraParameterBuilders) {
        [parameterBuilders addObjectsFromArray:extraParameterBuilders];
    }
   
    for (id<OXMParameterBuilder> builder in parameterBuilders) {
        [builder buildBidRequest:bidRequest];
    }
    
    return [OXMORTBParameterBuilder buildOpenRTBFor:bidRequest];
}

+ (nonnull OXMORTBBidRequest *)createORTBBidRequestWithTargeting:(nonnull OXATargeting *)targeting {
    OXMORTBBidRequest *bidRequest = [OXMORTBBidRequest new];
    
    bidRequest.user.yob = targeting.userAge > 0 ?
        @([OXAAgeUtils yobForAge:targeting.userAge])
        : nil;
    
    bidRequest.user.gender      = targeting.userGenderDescription;
    bidRequest.user.buyeruid    = targeting.buyerUID;
    bidRequest.user.keywords    = targeting.keywords;
    bidRequest.user.customdata  = targeting.userCustomData;
   
    if (targeting.userExt) {
        bidRequest.user.ext = targeting.userExt;
    }
    
    if (targeting.eids) {
        [bidRequest.user appendEids:targeting.eids];
    }
    
    bidRequest.app.storeurl = targeting.appStoreMarketURL;
    
    if (targeting.publisherName) {
        if (!bidRequest.app.publisher) {
            bidRequest.app.publisher = [[OXMORTBPublisher alloc] init];
        }
        
        bidRequest.app.publisher.name = targeting.publisherName;
    }
    
    bidRequest.device.carrier = targeting.carrier;
    bidRequest.device.connectiontype = @(targeting.networkType);
    
    NSValue * const coordObj = targeting.coordinate;
    if (coordObj) {
        const CLLocationCoordinate2D coord2d = coordObj.MKCoordinateValue;
        bidRequest.user.geo.lat = @(coord2d.latitude);
        bidRequest.user.geo.lon = @(coord2d.longitude);
    }
    
    return bidRequest;
}

@end
