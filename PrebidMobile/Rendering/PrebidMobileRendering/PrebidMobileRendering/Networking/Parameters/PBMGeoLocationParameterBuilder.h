//
//  PBMGeoLocationParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMParameterBuilderProtocol.h"

@class PBMLocationManager;

NS_SWIFT_NAME(GeoLocationParameterBuilder)
@interface PBMGeoLocationParameterBuilder : NSObject <PBMParameterBuilder>

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithLocationManager:(nonnull PBMLocationManager *)locationManager NS_DESIGNATED_INITIALIZER;

@end
