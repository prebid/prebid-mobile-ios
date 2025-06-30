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

#import "PBMORTBAbstract.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 3.2.19: Geo

//This object encapsulates various methods for specifying a geographic location. When subordinate to a
//Device object, it indicates the location of the device which can also be interpreted as the user’s current
//location. When subordinate to a User object, it indicates the location of the user’s home base (i.e., not
//necessarily their current location).
//The lat/lon attributes should only be passed if they conform to the accuracy depicted in the type
//attribute. For example, the centroid of a geographic region such as postal code should not be passed.
@interface PBMORTBGeo : PBMORTBAbstract

//Double. Longitude from -90.0 to 90.0 where negative is south
@property (nonatomic, strong, nullable) NSNumber *lat;

//Double. Latitude from -180.0 to 180.0 where negative is west
@property (nonatomic, strong, nullable) NSNumber *lon;

//Int. Source of the location data. See table 5.20 for details:
//1 GPS/Location Services
//2 IP Address
//3 User provided (e.g., registration data)
@property (nonatomic, strong, nullable) NSNumber *type;

//Integer. Estimated location accuracy in meters; recommended when
//lat/lon are specified and derived from a device’s location
//services (i.e., type = 1). Note that this is the accuracy as
//reported from the device. Consult OS specific documentation
//(e.g., Android, iOS) for exact interpretation.
@property (nonatomic, strong, nullable) NSNumber *accuracy;

//Number of seconds since this geolocation fix was established.
//Note that devices may cache location data across multiple
//fetches. Ideally, this value should be from the time the actual
//fix was taken.
@property (nonatomic, strong, nullable) NSNumber *lastfix;

//Service or provider used to determine geolocation from IP
//address if applicable (i.e., type = 2). Refer to List 5.23.
//ipservice is not supported

//Country code using ISO-3166-1-alpha-3
@property (nonatomic, copy, nullable) NSString *country;

//Region code using ISO-3166-2; 2-letter state code if USA
@property (nonatomic, copy, nullable) NSString *region;

//Region of a country using FIPS 10-4 notation. While OpenRTB supports this attribute, it has been withdrawn by NIST in 2008
@property (nonatomic, copy, nullable) NSString *regionfips104;

//Google metro code; similar to but not exactly Nielsen DMAs
//https://developers.google.com/adwords/api/docs/appendix/geotargeting?csw=1
@property (nonatomic, copy, nullable) NSString *metro;

//City using United Nations Code for Trade & Transport Locations
@property (nonatomic, copy, nullable) NSString *city;

//Zip or postal code
@property (nonatomic, copy, nullable) NSString *zip;

//Int. Local time as the number +/- of minutes from UTC
@property (nonatomic, strong, nullable) NSNumber *utcoffset;

@end

NS_ASSUME_NONNULL_END
