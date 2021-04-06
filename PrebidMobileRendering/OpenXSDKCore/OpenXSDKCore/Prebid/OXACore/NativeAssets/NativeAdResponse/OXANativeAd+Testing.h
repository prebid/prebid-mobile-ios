//
//  OXANativeAd+Testing.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAd+FromMarkup.h"

#import "OXASDKConfiguration.h"
#import "OXMOpenMeasurementWrapper.h"
#import "OXMServerConnectionProtocol.h"
#import "OXMUIApplicationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAd ()

- (instancetype)initWithNativeAdMarkup:(OXANativeAdMarkup *)nativeAdMarkup
                           application:(id<OXMUIApplicationProtocol>)application
                    measurementWrapper:(OXMOpenMeasurementWrapper *)measurementWrapper
                      serverConnection:(id<OXMServerConnectionProtocol>)serverConnection
                      sdkConfiguration:(OXASDKConfiguration *)sdkConfiguration;

@end

NS_ASSUME_NONNULL_END
