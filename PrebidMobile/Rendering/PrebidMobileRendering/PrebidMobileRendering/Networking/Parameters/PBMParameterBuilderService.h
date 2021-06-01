//
//  PBMParameterBuilderService.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@protocol PBMBundleProtocol;
@protocol PBMParameterBuilder;

@class PrebidRenderingTargeting;
@class PBMAdConfiguration;
@class PBMDeviceAccessManager;
@class PBMLocationManager;
@class PrebidRenderingConfig;
@class PBMUserConsentDataManager;
@class PBMReachability;

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
                                                                    sdkConfiguration:(nonnull PrebidRenderingConfig *)sdkConfiguration
                                                                          sdkVersion:(nonnull NSString *)sdkVersion
                                                               pbmUserConsentManager:(nonnull PBMUserConsentDataManager *)pbmUserConsentManager
                                                                           targeting:(nonnull PrebidRenderingTargeting *)targeting
                                                              extraParameterBuilders:(nullable NSArray<id<PBMParameterBuilder> > *)extraParameterBuilders;
@end
