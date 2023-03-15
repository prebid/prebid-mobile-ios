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

#import "PBMLocationManager.h"
#import "PBMConstants.h"
#import "PBMNSThreadProtocol.h"
#import "PBMMacros.h"

#import "PBMLocationManagerProtocol.h"
#import "PBMNSThreadProtocol.h"

@interface PBMLocationManager () <CLLocationManagerDelegate>
@property (strong, nullable) CLLocation *location;
@property (strong) id<PBMLocationManagerProtocol> locationManager;
@end

@implementation PBMLocationManager
# pragma mark - Init
+ (nonnull instancetype)shared {
    static PBMLocationManager *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PBMLocationManager alloc] initWithThread:[NSThread currentThread]];
    });
    return shared;
}

- (nonnull instancetype)initWithThread:(nonnull id<PBMNSThreadProtocol>)thread {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.location = nil;
    self.locationUpdatesEnabled = YES;
    [self initializeInternalLocationManagerInThread:thread];
    
    return self;
}

- (instancetype)initWithLocationManager:(id<PBMLocationManagerProtocol>)locationManager {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.location = nil;
    self.locationUpdatesEnabled = YES;
    [self setupWithLocationManager:locationManager];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

#pragma mark - Public

- (void)setLocationUpdatesEnabled:(BOOL)enabled {
    if (_locationUpdatesEnabled != enabled) {
        _locationUpdatesEnabled = enabled;
        
        if (_locationUpdatesEnabled) {
            [self startLocationUpdates];
        } else {
            [self stopLocationUpdates];
            self.location = nil;
        }
    }
}

- (BOOL)coordinatesAreValid {
    return [self locationIsValid: self.location];
}

- (CLLocationCoordinate2D)coordinates {
    return (self.coordinatesAreValid) ? self.location.coordinate : kCLLocationCoordinate2DInvalid;
}

- (CLLocationAccuracy) horizontalAccuracy {
    return (self.coordinatesAreValid) ? self.location.horizontalAccuracy : -1;
}

- (NSDate *) timestamp {
    return (self.coordinatesAreValid) ? self.location.timestamp : nil;
}

#pragma mark - Private
- (void)setupWithLocationManager:(id <PBMLocationManagerProtocol>)locationManager {
    self.locationManager = locationManager;
    
    self.locationManager.distanceFilter = PBMGeoLocationConstants.DISTANCE_FILTER;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    
    [self startLocationUpdates];
    
    // CLLocationManager's `location` property may already contain location data upon
    // initialization (for example, if the application uses significant location updates).
    CLLocation *existingLocation = self.locationManager.location;
    if ([self locationIsValid:existingLocation]) {
        self.location = existingLocation;
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self stopLocationUpdates];
    }];
    
    // Re-activate location updates when the application comes back to the foreground.
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self startLocationUpdates];
    }];
}


- (void)initializeInternalLocationManager {
    [self initializeInternalLocationManagerInThread:[NSThread currentThread]];
}

- (void)initializeInternalLocationManagerInThread:(id<PBMNSThreadProtocol>)thread {
    // CLLocationManager must be initialized on the main thread
    if (!thread.isMainThread) {
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if (!self) { return; }
            [self initializeInternalLocationManager];
        });
        return;
    }
    
    id <PBMLocationManagerProtocol> locationManager = [CLLocationManager<PBMLocationManagerProtocol> new];
    [self setupWithLocationManager:locationManager];
}


- (BOOL)isAuthorizedStatus:(CLAuthorizationStatus)status {
    return (status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse);
}

- (BOOL)locationIsValid:(CLLocation *)location {
    return location && [location isKindOfClass: [CLLocation class]] && CLLocationCoordinate2DIsValid(location.coordinate) && location.horizontalAccuracy > 0;
}

- (void)startLocationUpdates {
    
    if (!self.locationUpdatesEnabled) {
        return;
    }
    
    if (![self isAuthorizedStatus:[[self.locationManager class] authorizationStatus]]) {
        return;
    }
    
    [self.locationManager startUpdatingLocation];
}

- (void)stopLocationUpdates {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations { //!OCLINT(unused method parameter)
    CLLocation *newLocation = locations.lastObject;
    if ([self locationIsValid:newLocation]) {
        self.location = newLocation;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error { //!OCLINT(unused method parameter)
    [self stopLocationUpdates];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status { //!OCLINT(unused method parameter)
    if ([self isAuthorizedStatus:status]) {
        [self startLocationUpdates];
    }
}

@end
