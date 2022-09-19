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

#import "PBMGeoLocationParameterBuilder.h"
#import "PBMORTB.h"
#import "PBMLocationManager.h"
#import "PBMConstants.h"
#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

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
    if (Prebid.shared.shareGeoLocation == false) {
        return;;
    }
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
