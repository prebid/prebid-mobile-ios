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

#import <MapKit/MapKit.h>

#import "PBMAgeUtils.h"
#import "PBMAdConfiguration.h"
#import "PBMAppInfoParameterBuilder.h"
#import "PBMBasicParameterBuilder.h"
#import "PBMDeviceAccessManager.h"
#import "PBMDeviceInfoParameterBuilder.h"
#import "PBMFunctions.h"
#import "PBMGeoLocationParameterBuilder.h"
#import "PBMLocationManager.h"
#import "PBMLog.h"
#import "PBMNetworkParameterBuilder.h"
#import "PBMORTBParameterBuilder.h"
#import "PBMParameterBuilderProtocol.h"
#import "PBMSupportedProtocolsParameterBuilder.h"
#import "PBMSKAdNetworksParameterBuilder.h"
#import "PBMUserConsentDataManager.h"
#import "PBMUserConsentParameterBuilder.h"
#import "PBMORTB.h"

#import "PBMParameterBuilderService.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

@implementation PBMParameterBuilderService

+ (nonnull NSDictionary<NSString* , NSString *> *)buildParamsDictWithAdConfiguration:(nonnull PBMAdConfiguration *)adConfiguration {
    return [self buildParamsDictWithAdConfiguration:adConfiguration extraParameterBuilders:nil];
}

+ (nonnull NSDictionary<NSString* , NSString *> *)buildParamsDictWithAdConfiguration:(nonnull PBMAdConfiguration *)adConfiguration extraParameterBuilders:(nullable NSArray<id<PBMParameterBuilder> > *)extraParameterBuilders {
    return [self buildParamsDictWithAdConfiguration:adConfiguration
                                             bundle:NSBundle.mainBundle
                                 pbmLocationManager:PBMLocationManager.shared
                             pbmDeviceAccessManager:[[PBMDeviceAccessManager alloc] initWithRootViewController: nil]
                             ctTelephonyNetworkInfo:[CTTelephonyNetworkInfo new]
                                       reachability:[PBMReachability reachabilityForInternetConnection]
                                   sdkConfiguration:Prebid.shared
                                         sdkVersion:[PBMFunctions sdkVersion]
                              pbmUserConsentManager:PBMUserConsentDataManager.shared
                                          targeting:Targeting.shared
                             extraParameterBuilders:extraParameterBuilders];
}

// Input parameters validation: certain parameter will be validated in particular builder.
// In such case, even if some parameter is invalid all other builders will work.
+ (nonnull NSDictionary<NSString* , NSString *> *)buildParamsDictWithAdConfiguration:(nonnull PBMAdConfiguration *)adConfiguration
                                                                              bundle:(nonnull id<PBMBundleProtocol>)bundle
                                                                  pbmLocationManager:(nonnull PBMLocationManager *)pbmLocationManager
                                                              pbmDeviceAccessManager:(nonnull PBMDeviceAccessManager *)pbmDeviceAccessManager
                                                              ctTelephonyNetworkInfo:(nonnull CTTelephonyNetworkInfo *)ctTelephonyNetworkInfo
                                                                        reachability:(nonnull PBMReachability *)reachability
                                                                    sdkConfiguration:(nonnull Prebid *)sdkConfiguration
                                                                          sdkVersion:(nonnull NSString *)sdkVersion
                                                               pbmUserConsentManager:(nonnull PBMUserConsentDataManager *) pbmUserConsentManager
                                                                           targeting:(nonnull Targeting *)targeting
                                                              extraParameterBuilders:(nullable NSArray<id<PBMParameterBuilder> > *)extraParameterBuilders{
  
    PBMORTBBidRequest *bidRequest = [PBMParameterBuilderService createORTBBidRequestWithTargeting:targeting];
    NSMutableArray<id<PBMParameterBuilder> > * const parameterBuilders = [[NSMutableArray alloc] init];
    [parameterBuilders addObjectsFromArray:@[
        [[PBMBasicParameterBuilder alloc] initWithAdConfiguration:adConfiguration
                                                 sdkConfiguration:sdkConfiguration
                                                       sdkVersion:sdkVersion
                                                        targeting:targeting],
        [[PBMGeoLocationParameterBuilder alloc] initWithLocationManager:pbmLocationManager],
        [[PBMAppInfoParameterBuilder alloc] initWithBundle:bundle targeting:targeting],
        [[PBMDeviceInfoParameterBuilder alloc] initWithDeviceAccessManager:pbmDeviceAccessManager userConsentManager:pbmUserConsentManager],
        [[PBMNetworkParameterBuilder alloc] initWithCtTelephonyNetworkInfo:ctTelephonyNetworkInfo reachability:reachability],
        [[PBMSupportedProtocolsParameterBuilder alloc] initWithSDKConfiguration:sdkConfiguration],
        [[PBMUserConsentParameterBuilder alloc] initWithUserConsentManager:pbmUserConsentManager],
        [[PBMSKAdNetworksParameterBuilder alloc] initWithBundle:bundle targeting:targeting],
    ]];
    
    if (extraParameterBuilders) {
        [parameterBuilders addObjectsFromArray:extraParameterBuilders];
    }
   
    for (id<PBMParameterBuilder> builder in parameterBuilders) {
        [builder buildBidRequest:bidRequest];
    }
    
    return [PBMORTBParameterBuilder buildOpenRTBFor:bidRequest];
}

+ (nonnull PBMORTBBidRequest *)createORTBBidRequestWithTargeting:(nonnull Targeting *)targeting {
    PBMORTBBidRequest *bidRequest = [PBMORTBBidRequest new];
    
    bidRequest.user.yob = targeting.userAge > 0 ?
        @([PBMAgeUtils yobForAge:targeting.userAge.intValue])
        : nil;
    
    bidRequest.user.gender      = targeting.userGenderDescription;
    bidRequest.user.buyeruid    = targeting.buyerUID;
    bidRequest.user.keywords    = targeting.keywords;
    bidRequest.user.customdata  = targeting.userCustomData;
   
    if (targeting.userExt) {
        bidRequest.user.ext = [targeting.userExt mutableCopy];
    }
    
    if (targeting.eids) {
        [bidRequest.user appendEids:targeting.eids];
    }
    
    bidRequest.app.storeurl = targeting.appStoreMarketURL;
    
    if (targeting.publisherName) {
        if (!bidRequest.app.publisher) {
            bidRequest.app.publisher = [[PBMORTBPublisher alloc] init];
        }
        
        bidRequest.app.publisher.name = targeting.publisherName;
    }
        
    NSValue * const coordObj = targeting.coordinate;
    if (coordObj) {
        const CLLocationCoordinate2D coord2d = coordObj.MKCoordinateValue;
        bidRequest.user.geo.lat = @(coord2d.latitude);
        bidRequest.user.geo.lon = @(coord2d.longitude);
    }
    
    return bidRequest;
}

@end
