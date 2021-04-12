//
//  OXMORTBVideo.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBVideo.h"
#import "OXMORTBAbstract+Protected.h"

//This object represents an in-stream video impression. Many of the fields are non-essential for minimally viable transactions, but are included to offer fine control when needed. Video in OpenRTB generally assumes compliance with the VAST standard. As such, the notion of companion ads is supported by optionally including an array of Banner objects that define these companion ads.
@implementation OXMORTBVideo

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _mimes = OXMConstants.supportedVideoMimeTypes;
    _protocols = @[@(2),@(5)];
    _playbackend = @(2);
    _delivery = @[@(3)];
    _pos = @(7);
    _api = @[];
    
    return self;
}

- (void)setMimes:(NSArray<NSString *> *)mimes {
    _mimes = mimes ? [NSArray arrayWithArray:mimes] : @[];
}

- (void)setProtocols:(NSArray<NSNumber *> *)protocols {
    _protocols = protocols ? [NSArray arrayWithArray:protocols] : @[];
}

- (void)setDelivery:(NSArray<NSNumber *> *)delivery {
    _delivery = delivery ? [NSArray arrayWithArray:delivery] : nil;
}

- (void)setApi:(NSArray<NSNumber *> *)api {
    _api = api ? [NSArray arrayWithArray:api] : nil;
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    ret[@"mimes"] = self.mimes;
    ret[@"minduration"] = self.minduration;
    ret[@"maxduration"] = self.maxduration;
    ret[@"protocols"] = self.protocols;
    ret[@"w"] = self.w;
    ret[@"h"] = self.h;
    ret[@"startdelay"] = self.startdelay;
    ret[@"placement"] = self.placement;
    ret[@"linearity"] = self.linearity;
    ret[@"minbitrate"] = self.minbitrate;
    ret[@"maxbitrate"] = self.maxbitrate;
    ret[@"playbackend"] = self.playbackend;
    ret[@"delivery"] = self.delivery;
    ret[@"pos"] = self.pos;
    if (self.api.count > 0) {
        ret[@"api"] = self.api;
    }
    
    ret = [ret oxmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
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
