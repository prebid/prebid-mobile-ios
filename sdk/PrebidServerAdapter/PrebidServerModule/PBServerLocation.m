/*   Copyright 2017 Prebid.org, Inc.
 
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

#import "PBServerLocation.h"

static NSInteger const kPBSLocationMaxLocationPrecision = 6;
static NSInteger const kPBSLocationDefaultHorizontalAccuracy = 100;

@interface PBServerLocation ()

@property (nonatomic, readwrite, assign) NSInteger precision;

@end

@implementation PBServerLocation

+ (PBServerLocation *)getLocationWithLatitude:(CGFloat)latitude
                                          longitude:(CGFloat)longitude
                                          timestamp:(NSDate *)timestamp
                                 horizontalAccuracy:(CGFloat)horizontalAccuracy {
    return [PBServerLocation getLocationWithLatitude:latitude
                                                 longitude:longitude
                                                 timestamp:timestamp
                                        horizontalAccuracy:horizontalAccuracy
                                                 precision:-1];
}

+ (PBServerLocation *)getLocationWithLatitude:(CGFloat)latitude
                                          longitude:(CGFloat)longitude
                                          timestamp:(NSDate *)timestamp
                                 horizontalAccuracy:(CGFloat)horizontalAccuracy
                                          precision:(NSInteger)precision {
    BOOL invalidLatitude = latitude < -90 || latitude > 90;
    BOOL invalidLongitude = longitude < -180 || longitude > 180;
    BOOL invalidHorizontalAccuracy = horizontalAccuracy < 0;
    if (invalidLatitude || invalidLongitude || invalidHorizontalAccuracy) {
        return nil;
    }
    
    BOOL invalidPrecision = precision < -1;
    if (invalidPrecision) {
        //Log
    }
    
    if (horizontalAccuracy == 0)
        horizontalAccuracy = kPBSLocationDefaultHorizontalAccuracy;
    
    if (timestamp == nil)
        timestamp = [NSDate date];
    
    PBServerLocation *location = [[PBServerLocation alloc] init];
    if (precision <= -1) {
        location.latitude = latitude;
        location.longitude = longitude;
        location.precision = -1;
    } else {
        NSInteger effectivePrecision = precision;
        if (precision > kPBSLocationMaxLocationPrecision) {
            effectivePrecision = kPBSLocationMaxLocationPrecision;
        }
        
        CGFloat precisionFloat = powf(10, effectivePrecision);
        location.latitude = roundf(latitude * precisionFloat) / precisionFloat;
        location.longitude = roundf(longitude * precisionFloat) / precisionFloat;
        location.precision = effectivePrecision;
    }
    location.timestamp = timestamp;
    location.horizontalAccuracy = horizontalAccuracy;
    return location;
}

@end
