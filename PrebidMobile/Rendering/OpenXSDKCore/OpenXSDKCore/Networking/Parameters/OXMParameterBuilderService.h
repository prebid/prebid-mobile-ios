//
//  OXMParameterBuilderService.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@protocol OXMBundleProtocol;
@protocol OXMParameterBuilder;

@class OXATargeting;
@class OXMAdConfiguration;
@class OXMDeviceAccessManager;
@class OXMLocationManager;
@class OXASDKConfiguration;
@class OXMUserConsentDataManager;
@class OXMReachability;

@interface OXMParameterBuilderService : NSObject

//API Version
+ (nonnull NSDictionary<NSString* , NSString *> *)buildParamsDictWithAdConfiguration:(nonnull OXMAdConfiguration *)adConfiguration;

+ (nonnull NSDictionary<NSString* , NSString *> *)buildParamsDictWithAdConfiguration:(nonnull OXMAdConfiguration *)adConfiguration
                                                              extraParameterBuilders:(nullable NSArray<id<OXMParameterBuilder> > *)extraParameterBuilders;

//DI Version
+ (nonnull NSDictionary<NSString* , NSString *> *)buildParamsDictWithAdConfiguration:(nonnull OXMAdConfiguration *)adConfiguration
                                                                              bundle:(nonnull id<OXMBundleProtocol>)bundle
                                                                  oxmLocationManager:(nonnull OXMLocationManager *)oxmLocationManager
                                                              oxmDeviceAccessManager:(nonnull OXMDeviceAccessManager *)oxmDeviceAccessManager
                                                              ctTelephonyNetworkInfo:(nonnull CTTelephonyNetworkInfo *)ctTelephonyNetworkInfo
                                                                        reachability:(nonnull OXMReachability *)reachability
                                                                    sdkConfiguration:(nonnull OXASDKConfiguration *)sdkConfiguration
                                                                          sdkVersion:(nonnull NSString *)sdkVersion
                                                               oxmUserConsentManager:(nonnull OXMUserConsentDataManager *)oxmUserConsentManager
                                                                           targeting:(nonnull OXATargeting *)targeting
                                                              extraParameterBuilders:(nullable NSArray<id<OXMParameterBuilder> > *)extraParameterBuilders;
@end
