//
//  PBMORTBDeal.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBDeal.h"
#import "PBMORTBAbstract+Protected.h"

@implementation PBMORTBDeal

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

- (nonnull PBMJsonDictionary *)toJsonDictionary {
    PBMMutableJsonDictionary *ret = [PBMMutableJsonDictionary new];
    
    ret[@"id"] = self.id;
    ret[@"bidfloor"] = self.bidfloor;
    ret[@"bidfloorcur"] = self.bidfloorcur;
    ret[@"at"] = self.at;
    ret[@"wseat"] = self.wseat;
    ret[@"wadomain"] = self.wadomain;
    
    ret = [ret pbmCopyWithoutEmptyVals];
    
    return ret;
}

- (instancetype)initWithJsonDictionary:(nonnull PBMJsonDictionary *)jsonDictionary {
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
