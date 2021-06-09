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

#import "PBMORTBGeo.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBGeo

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"lat"] = self.lat ? [NSDecimalNumber decimalNumberWithDecimal:[self.lat decimalValue]] : nil;
    ret[@"lon"] = self.lon ? [NSDecimalNumber decimalNumberWithDecimal:[self.lon decimalValue]] : nil;
    ret[@"type"] = self.type;
    ret[@"accuracy"] = self.accuracy;
    ret[@"lastfix"] = self.lastfix;
    ret[@"country"] = self.country;
    ret[@"region"] = self.region;
    ret[@"regionfips104"] = self.regionfips104;
    ret[@"metro"] = self.metro;
    ret[@"city"] = self.city;
    ret[@"zip"] = self.zip;
    ret[@"utcoffset"] = self.utcoffset;
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _lat = jsonDictionary[@"lat"];
    _lon = jsonDictionary[@"lon"];
    _type = jsonDictionary[@"type"];
    _accuracy = jsonDictionary[@"accuracy"];
    _lastfix = jsonDictionary[@"lastfix"];
    _country = jsonDictionary[@"country"];
    _region = jsonDictionary[@"region"];
    _regionfips104 = jsonDictionary[@"regionfips104"];
    _metro = jsonDictionary[@"metro"];
    _city = jsonDictionary[@"city"];
    _zip = jsonDictionary[@"zip"];
    _utcoffset = jsonDictionary[@"utcoffset"];
    
    return self;
}

@end
