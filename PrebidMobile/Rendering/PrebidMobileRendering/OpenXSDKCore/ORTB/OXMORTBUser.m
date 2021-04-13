//
//  OXMORTBUser.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBUser.h"
#import "OXMORTBAbstract+Protected.h"

#import "OXMORTBGeo.h"

@implementation OXMORTBUser

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _geo = [OXMORTBGeo new];
    _ext = [OXMMutableJsonDictionary new];
    
    return self;
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    ret[@"yob"] = self.yob;
    ret[@"gender"] = self.gender;
    ret[@"buyeruid"] = self.buyeruid;
    ret[@"keywords"] = self.keywords;
    ret[@"customdata"] = self.customdata;
    
    if (self.geo.lat && self.geo.lon) {
        ret[@"geo"] = [self.geo toJsonDictionary];
    }

    if (self.ext && self.ext.count) {
        ret[@"ext"] = self.ext;
    }
    
    ret = [ret oxmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _yob         = jsonDictionary[@"yob"];
    _gender      = jsonDictionary[@"gender"];
    _buyeruid    = jsonDictionary[@"buyeruid"];
    _keywords    = jsonDictionary[@"keywords"];
    _customdata  = jsonDictionary[@"customdata"];
    _ext         = jsonDictionary[@"ext"];
        
    _geo = [[OXMORTBGeo alloc] initWithJsonDictionary:jsonDictionary[@"geo"]];
    
    return self;
}

- (void)appendEids:(NSArray<NSDictionary<NSString *, id> *> *)eids {
    
    if (!self.ext[@"eids"]) {
        self.ext[@"eids"] = eids;
    } else {
        NSArray *currentEids = (NSArray<NSDictionary<NSString *, id> *> *)self.ext[@"eids"];
        
        self.ext[@"eids"] = [currentEids arrayByAddingObjectsFromArray:eids];
    }
}


@end
