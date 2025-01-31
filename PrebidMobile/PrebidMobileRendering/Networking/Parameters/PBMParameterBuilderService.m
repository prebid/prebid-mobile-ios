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

#import "PBMAppInfoParameterBuilder.h"
#import "PBMBasicParameterBuilder.h"
#import "PBMDeviceAccessManager.h"
#import "PBMDeviceInfoParameterBuilder.h"
#import "PBMFunctions.h"
#import "PBMGeoLocationParameterBuilder.h"
#import "PBMLocationManager.h"
#import "PBMNetworkParameterBuilder.h"
#import "PBMORTBParameterBuilder.h"
#import "PBMParameterBuilderProtocol.h"
#import "PBMSKAdNetworksParameterBuilder.h"
#import "PBMUserConsentParameterBuilder.h"
#import "PBMORTB.h"

#import "PBMParameterBuilderService.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

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
                                       reachability:PBMReachability.shared
                                   sdkConfiguration:Prebid.shared
                                         sdkVersion:[PBMFunctions sdkVersion]
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
                                                                           targeting:(nonnull Targeting *)targeting
                                                              extraParameterBuilders:(nullable NSArray<id<PBMParameterBuilder> > *)extraParameterBuilders{
  
    PBMORTBBidRequest *bidRequest = [PBMParameterBuilderService createORTBBidRequestWithTargeting:targeting];
    bidRequest.ortbObject = [adConfiguration getCheckedOrtbConfig];
    NSMutableArray<id<PBMParameterBuilder> > * const parameterBuilders = [[NSMutableArray alloc] init];
    [parameterBuilders addObjectsFromArray:@[
        [[PBMBasicParameterBuilder alloc] initWithAdConfiguration:adConfiguration
                                                 sdkConfiguration:sdkConfiguration
                                                       sdkVersion:sdkVersion
                                                        targeting:targeting],
        [[PBMGeoLocationParameterBuilder alloc] initWithLocationManager:pbmLocationManager],
        [[PBMAppInfoParameterBuilder alloc] initWithBundle:bundle targeting:targeting],
        [[PBMDeviceInfoParameterBuilder alloc] initWithDeviceAccessManager:pbmDeviceAccessManager],
        [[PBMNetworkParameterBuilder alloc] initWithCtTelephonyNetworkInfo:ctTelephonyNetworkInfo
                                                              reachability:reachability],
        [[PBMUserConsentParameterBuilder alloc] init],
        [[PBMSKAdNetworksParameterBuilder alloc] initWithBundle:bundle
                                                      targeting:targeting
                                                adConfiguration:adConfiguration],
    ]];
    
    if (extraParameterBuilders) {
        [parameterBuilders addObjectsFromArray:extraParameterBuilders];
    }
   
    for (id<PBMParameterBuilder> builder in parameterBuilders) {
        [builder buildBidRequest:bidRequest];
    }
    
    NSDictionary *ortb = [bidRequest toJsonDictionary];
    
    NSDictionary * arbitratyORTB = [PBMArbitraryORTBService mergeWithSdkORTB:ortb
                                                                     impORTB:adConfiguration.impORTBConfig
                                                                  globalORTB:[targeting getGlobalORTBConfig]];
    
    return [PBMORTBParameterBuilder buildOpenRTBFor:arbitratyORTB];
}

+ (nonnull PBMORTBBidRequest *)createORTBBidRequestWithTargeting:(nonnull Targeting *)targeting {
    PBMORTBBidRequest *bidRequest = [PBMORTBBidRequest new];
    NSNumber * yob = [targeting getYearOfBirth];
    
    if (![yob isEqual:@0]) {
        bidRequest.user.yob = yob;
    }
    
    bidRequest.user.gender      = targeting.userGenderDescription;
    bidRequest.user.buyeruid    = targeting.buyerUID;
    bidRequest.user.customdata  = targeting.userCustomData;
    bidRequest.user.userid      = targeting.userID;
   
    if (targeting.userExt) {
        NSMutableDictionary *existingUserExt = bidRequest.user.ext ?: [NSMutableDictionary dictionary];
        [existingUserExt addEntriesFromDictionary:targeting.userExt];
        bidRequest.user.ext = existingUserExt;
    }
    
    if ([targeting getExternalUserIds]) {
        [bidRequest.user appendEids:[targeting getExternalUserIds]];
    }
    
    if (targeting.sendSharedId) {
        __auto_type sharedId = targeting.sharedId;
        if (sharedId) {
            [bidRequest.user appendEids:@[[sharedId toJSONDictionary]]];
        }
    }
    
    if ([targeting getUserKeywords].count > 0) {
        bidRequest.user.keywords = [[targeting getUserKeywords] componentsJoinedByString:@","];
    }
    
    bidRequest.app.storeurl = targeting.storeURL;
    bidRequest.app.domain = targeting.domain;
    bidRequest.app.bundle = targeting.itunesID;
    
    if ([targeting getAppKeywords].count > 0) {
        bidRequest.app.keywords = [[targeting getAppKeywords] componentsJoinedByString:@","];
    }
    
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
