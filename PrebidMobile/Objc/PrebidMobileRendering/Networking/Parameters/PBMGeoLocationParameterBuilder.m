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
#import "PBMConstants.h"
#import "PBMMacros.h"
#import "Log+Extensions.h"

#import "SwiftImport.h"

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
        // Rounds with the precision defined in Targeting, or returns the original coordinates if precision is nil.
        CLLocationCoordinate2D coordinates = [[Utils shared] roundWithCoordinates:self.locationManager.coordinates precision:[[Targeting shared] locationPrecision]];
        bidRequest.device.geo.type = @(PrebidConstants.LOCATION_SOURCE_GPS);
        bidRequest.device.geo.lat = @(coordinates.latitude);
        bidRequest.device.geo.lon = @(coordinates.longitude);
    }
}

@end
