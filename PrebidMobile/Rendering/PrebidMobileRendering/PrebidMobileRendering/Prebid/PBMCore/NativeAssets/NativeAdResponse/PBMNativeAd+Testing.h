//
//  PBMNativeAd+Testing.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMNativeAd+FromMarkup.h"

#import "PBMSDKConfiguration.h"
#import "PBMOpenMeasurementWrapper.h"
#import "PBMServerConnectionProtocol.h"
#import "PBMUIApplicationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAd ()

- (instancetype)initWithNativeAdMarkup:(PBMNativeAdMarkup *)nativeAdMarkup
                           application:(id<PBMUIApplicationProtocol>)application
                    measurementWrapper:(PBMOpenMeasurementWrapper *)measurementWrapper
                      serverConnection:(id<PBMServerConnectionProtocol>)serverConnection
                      sdkConfiguration:(PBMSDKConfiguration *)sdkConfiguration;

@end

NS_ASSUME_NONNULL_END
