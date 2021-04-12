//
//  OXMGeoLocationParameterBuilder.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXMParameterBuilderProtocol.h"

@class OXMLocationManager;

NS_SWIFT_NAME(GeoLocationParameterBuilder)
@interface OXMGeoLocationParameterBuilder : NSObject <OXMParameterBuilder>

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithLocationManager:(nonnull OXMLocationManager *)locationManager NS_DESIGNATED_INITIALIZER;

@end
