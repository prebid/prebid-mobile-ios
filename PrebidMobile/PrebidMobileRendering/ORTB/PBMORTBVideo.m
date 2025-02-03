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

#import "PBMORTBVideo.h"
#import "PBMORTBAbstract+Protected.h"

//This object represents an in-stream video impression. Many of the fields are non-essential for minimally viable transactions, but are included to offer fine control when needed. Video in OpenRTB generally assumes compliance with the VAST standard. As such, the notion of companion ads is supported by optionally including an array of Banner objects that define these companion ads.
@implementation PBMORTBVideo

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    
    return self;
}

- (void)setMimes:(NSArray<NSString *> *)mimes {
    _mimes = mimes ? [NSArray arrayWithArray:mimes] : nil;
}

- (void)setProtocols:(NSArray<NSNumber *> *)protocols {
    _protocols = protocols ? [NSArray arrayWithArray:protocols] : nil;
}

- (void)setDelivery:(NSArray<NSNumber *> *)delivery {
    _delivery = delivery ? [NSArray arrayWithArray:delivery] : nil;
}

- (void)setApi:(NSArray<NSNumber *> *)api {
    _api = api ? [NSArray arrayWithArray:api] : nil;
}

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"mimes"] = self.mimes;
    ret[@"minduration"] = self.minduration;
    ret[@"maxduration"] = self.maxduration;
    ret[@"protocols"] = self.protocols;
    ret[@"w"] = self.w;
    ret[@"h"] = self.h;
    ret[@"startdelay"] = self.startdelay;
    ret[@"placement"] = self.placement;
    ret[@"plcmt"] = self.plcmt;
    ret[@"linearity"] = self.linearity;
    ret[@"minbitrate"] = self.minbitrate;
    ret[@"maxbitrate"] = self.maxbitrate;
    ret[@"playbackend"] = self.playbackend;
    ret[@"delivery"] = self.delivery;
    ret[@"pos"] = self.pos;
    if (self.api.count > 0) {
        ret[@"api"] = self.api;
    }
    
    if (self.playbackmethod > 0) {
        ret[@"playbackmethod"] = self.playbackmethod;
    }
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _mimes = jsonDictionary[@"mimes"];
    _minduration = jsonDictionary[@"minduration"];
    _maxduration = jsonDictionary[@"maxduration"];
    _protocols = jsonDictionary[@"protocols"];
    _w = jsonDictionary[@"w"];
    _h = jsonDictionary[@"h"];
    _startdelay = jsonDictionary[@"startdelay"];
    _placement = jsonDictionary[@"placement"];
    _plcmt = jsonDictionary[@"plcmt"];
    _linearity = jsonDictionary[@"linearity"];
    _minbitrate = jsonDictionary[@"minbitrate"];
    _maxbitrate = jsonDictionary[@"maxbitrate"];
    _playbackend = jsonDictionary[@"playbackend"];
    _delivery = jsonDictionary[@"delivery"];
    _pos = jsonDictionary[@"pos"];
    _api = jsonDictionary[@"api"];
    
    return self;
}

@end
