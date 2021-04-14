//
//  OXMORTBDeal.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBDeal.h"
#import "OXMORTBAbstract+Protected.h"

@implementation OXMORTBDeal

- (nonnull instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _bidfloor = @(0.0);
    _bidfloorcur = @"USD";
    _wseat = @[];
    _wadomain = @[];
    
    return self;
}
- (void)setWseat:(NSArray<NSString *> *)wseat {
    _wseat = wseat ? [NSArray arrayWithArray:wseat] : @[];
}
- (void)setWadomain:(NSArray<NSString *> *)wadomain {
    _wadomain = wadomain ? [NSArray arrayWithArray:wadomain] : @[];
}

- (nonnull OXMJsonDictionary *)toJsonDictionary {
    OXMMutableJsonDictionary *ret = [OXMMutableJsonDictionary new];
    
    ret[@"id"] = self.id;
    ret[@"bidfloor"] = self.bidfloor;
    ret[@"bidfloorcur"] = self.bidfloorcur;
    ret[@"at"] = self.at;
    ret[@"wseat"] = self.wseat;
    ret[@"wadomain"] = self.wadomain;
    
    ret = [ret oxmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull OXMJsonDictionary *)jsonDictionary {
    if (!(self = [self init])) {
        return nil;
    }
    _id = jsonDictionary[@"id"];
    _bidfloor = jsonDictionary[@"bidfloor"];
    _bidfloorcur = jsonDictionary[@"bidfloorcur"];
    _at = jsonDictionary[@"at"];
    _wseat = jsonDictionary[@"wseat"];
    _wadomain = jsonDictionary[@"wadomain"];
    
    return self;
}

@end
