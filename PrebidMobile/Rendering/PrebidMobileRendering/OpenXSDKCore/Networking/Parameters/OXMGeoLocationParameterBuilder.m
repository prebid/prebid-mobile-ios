//
//  OXMGeoLocationParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMGeoLocationParameterBuilder.h"
#import "OXMORTB.h"
#import "OXMLocationManager.h"
#import "OXMConstants.h"
#import "OXMMacros.h"

#pragma mark - Internal Extension

@interface OXMGeoLocationParameterBuilder()

@property (nonatomic, strong) OXMLocationManager *locationManager;

@end

#pragma mark - Implementation

@implementation OXMGeoLocationParameterBuilder

#pragma mark - Initialization

- (nonnull instancetype)initWithLocationManager:(nonnull OXMLocationManager *)locationManager {
    self = [super init];
    if (self) {
        OXMAssert(locationManager);
        
        self.locationManager = locationManager;
    }
    
    return self;
}

#pragma mark - OXMParameterBuilder

- (void)buildBidRequest:(OXMORTBBidRequest *)bidRequest {
    if (!(self.locationManager && bidRequest)) {
        OXMLogError(@"Invalid properties");
        return;
    }
    
    if (self.locationManager.coordinatesAreValid) {
        CLLocationCoordinate2D coordinates = self.locationManager.coordinates;
        bidRequest.device.geo.type = @(OXALocationSourceValuesGPS);
        bidRequest.device.geo.lat = @(coordinates.latitude);
        bidRequest.device.geo.lon = @(coordinates.longitude);
    }
}

@end
