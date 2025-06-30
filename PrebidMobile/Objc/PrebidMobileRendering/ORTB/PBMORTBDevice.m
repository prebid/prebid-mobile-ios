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

#import "PBMORTBDevice.h"
#import "PBMORTBAbstract+Protected.h"
#import "PBMORTBDeviceExtAtts.h"
#import "PBMORTBDeviceExtPrebid.h"

#import "PBMORTBGeo.h"

@implementation PBMORTBDevice

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _geo = [PBMORTBGeo new];
    _extPrebid = [[PBMORTBDeviceExtPrebid alloc] init];
    _extAtts = [PBMORTBDeviceExtAtts new];
    
    return self;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"ua"] = self.ua;
    ret[@"geo"] = [[self.geo toJsonDictionary] nullIfEmpty];
    ret[@"lmt"] = self.lmt;
    ret[@"devicetype"] = self.devicetype;
    ret[@"make"] = self.make;
    ret[@"model"] = self.model;
    ret[@"os"] = self.os;
    ret[@"osv"] = self.osv;
    ret[@"h"] = self.h;
    ret[@"w"] = self.w;
    ret[@"ppi"] = self.ppi;
    ret[@"pxratio"] = self.pxratio;
    ret[@"js"] = self.js;
    ret[@"geofetch"] = self.geofetch;
    ret[@"flashver"] = self.flashver;
    ret[@"language"] = self.language;
    ret[@"carrier"] = self.carrier;
    ret[@"mccmnc"] = self.mccmnc;
    ret[@"connectiontype"] = self.connectiontype;
    ret[@"didsha1"] = self.didsha1;
    ret[@"didmd5"] = self.didmd5;
    ret[@"hwv"] = self.hwv;
    
    if (self.ifa) {
        ret[@"ifa"] = self.ifa;
    } else {
        ret[@"dpidsha1"] = self.dpidsha1;
        ret[@"dpidmd5"] = self.dpidmd5;
        ret[@"macsha1"] = self.macsha1;
        ret[@"macmd5"] = self.macmd5;
    }
    
    PBMJsonDictionary * const extPrebidDic = [self.extPrebid toJsonDictionary];
    if (extPrebidDic.count > 0) {
        ret[@"ext"] = @{@"prebid": extPrebidDic};
    }
    
    PBMJsonDictionary * const extAttsDict = [self.extAtts toJsonDictionary];
    if (extAttsDict.count > 0) {
        ret[@"ext"] = [NSMutableDictionary dictionaryWithDictionary:ret[@"ext"] ?: @{}];
        [ret[@"ext"] addEntriesFromDictionary:extAttsDict];
    }
    
    [ret pbmRemoveEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }

    _ua =  jsonDictionary[@"ua"] ;
    _geo = [[PBMORTBGeo alloc] initWithJsonDictionary:jsonDictionary[@"geo"]];
    _lmt =  jsonDictionary[@"lmt"];
    _devicetype = jsonDictionary[@"devicetype"];
    _make = jsonDictionary[@"make"];
    _model = jsonDictionary[@"model"];
    _os = jsonDictionary[@"os"] ;
    _osv = jsonDictionary[@"osv"];
    _hwv = jsonDictionary[@"hwv"];
    _h = jsonDictionary[@"h"];
    _w = jsonDictionary[@"w"];
    _ppi = jsonDictionary[@"ppi"];
    _pxratio = jsonDictionary[@"pxratio"];
    _js = jsonDictionary[@"js"] ;
    _geofetch = jsonDictionary[@"geofetch"];
    _flashver = jsonDictionary[@"flashver"];
    _language = jsonDictionary[@"language"];
    _carrier = jsonDictionary[@"carrier"];
    _mccmnc = jsonDictionary[@"mccmnc"];
    _connectiontype = jsonDictionary[@"connectiontype"];
    _ifa = jsonDictionary[@"ifa"];
    _didsha1 = jsonDictionary[@"didsha1"] ;
    _didmd5 = jsonDictionary[@"didmd5"];
    _dpidsha1 = jsonDictionary[@"dpidsha1"];
    _dpidmd5 = jsonDictionary[@"dpidmd5"];
    _macsha1 =  jsonDictionary[@"macsha1"];
    _macmd5 = jsonDictionary[@"macmd5"];
    _extPrebid = [[PBMORTBDeviceExtPrebid alloc] initWithJsonDictionary:jsonDictionary[@"ext"][@"prebid"]];
    _extAtts = [[PBMORTBDeviceExtAtts alloc] initWithJsonDictionary:jsonDictionary[@"ext"]];
    
    return self;
}

@end
