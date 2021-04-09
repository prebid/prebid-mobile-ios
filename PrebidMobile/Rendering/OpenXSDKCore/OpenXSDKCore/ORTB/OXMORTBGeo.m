//
//  OXMORTBGeo.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBGeo.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXMORTBGeo

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
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

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
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
