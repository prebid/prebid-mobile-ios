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

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

@protocol PBMBundleProtocol;
@protocol PBMParameterBuilder;

@class Targeting;
@class PBMAdConfiguration;
@class PBMDeviceAccessManager;
@class PBMLocationManager;
@class Prebid;
@class PBMArbitraryORTBParameterBuilder;

@interface PBMParameterBuilderService : NSObject

//API Version
+ (nonnull NSDictionary<NSString* , NSString *> *)buildParamsDictWithAdConfiguration:(nonnull PBMAdConfiguration *)adConfiguration;

+ (nonnull NSDictionary<NSString* , NSString *> *)buildParamsDictWithAdConfiguration:(nonnull PBMAdConfiguration *)adConfiguration
                                                              extraParameterBuilders:(nullable NSArray<id<PBMParameterBuilder> > *)extraParameterBuilders;

//DI Version
+ (nonnull NSDictionary<NSString* , NSString *> *)buildParamsDictWithAdConfiguration:(nonnull PBMAdConfiguration *)adConfiguration
                                                                              bundle:(nonnull id<PBMBundleProtocol>)bundle
                                                                  pbmLocationManager:(nonnull PBMLocationManager *)pbmLocationManager
                                                              pbmDeviceAccessManager:(nonnull PBMDeviceAccessManager *)pbmDeviceAccessManager
                                                              ctTelephonyNetworkInfo:(nonnull CTTelephonyNetworkInfo *)ctTelephonyNetworkInfo
                                                                        reachability:(nonnull PBMReachability *)reachability
                                                                    sdkConfiguration:(nonnull Prebid *)sdkConfiguration
                                                                          sdkVersion:(nonnull NSString *)sdkVersion
                                                                           targeting:(nonnull Targeting *)targeting
                                                              extraParameterBuilders:(nullable NSArray<id<PBMParameterBuilder> > *)extraParameterBuilders;
@end
