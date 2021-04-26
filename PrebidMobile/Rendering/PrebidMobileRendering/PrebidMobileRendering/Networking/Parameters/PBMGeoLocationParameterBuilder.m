//
//  PBMGeoLocationParameterBuilder.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMGeoLocationParameterBuilder.h"
#import "PBMORTB.h"
#import "PBMLocationManager.h"
#import "PBMConstants.h"
#import "PBMMacros.h"

#pragma mark - Internal Extension

@interface PBMGeoLocationParameterBuilder()

@property (nonatomic, strong) PBMLocationManager *locationManager;

@end

#pragma mark - Implementation

@implementation PBMGeoLocationParameterBuilder

#pragma mark - Initialization

- (nonnull instancetype)initWithLocationManager:(nonnull PBMLocationManager *)locationManager {
    self = [super init];
    if (self) {
        PBMAssert(locationManager);
        
        self.locationManager = locationManager;
    }
    
    return self;
}

#pragma mark - PBMParameterBuilder

- (void)buildBidRequest:(PBMORTBBidRequest *)bidRequest {
    if (!(self.locationManager && bidRequest)) {
        PBMLogError(@"Invalid properties");
        return;
    }
    
    if (self.locationManager.coordinatesAreValid) {
        CLLocationCoordinate2D coordinates = self.locationManager.coordinates;
        bidRequest.device.geo.type = @(PBMLocationSourceValuesGPS);
        bidRequest.device.geo.lat = @(coordinates.latitude);
        bidRequest.device.geo.lon = @(coordinates.longitude);
    }
}

@end
