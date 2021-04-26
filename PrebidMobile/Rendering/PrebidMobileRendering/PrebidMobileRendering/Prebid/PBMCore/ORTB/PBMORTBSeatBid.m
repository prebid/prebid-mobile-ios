//
//  PBMORTBSeatBid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBSeatBid.h"
#import "PBMORTBSeatBid+Internal.h"

#import "PBMORTBBid.h"

@implementation PBMORTBSeatBid

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _bid = @[[[PBMORTBBid alloc] init]];
    return self;
}

- (void)setBid:(NSArray<PBMORTBBid *> *)bid {
    BOOL hasBids = NO;
    for(PBMORTBBid *nextBid in bid) {
        if (nextBid) {
            hasBids = YES;
            break;
        }
    }
    _bid = hasBids ? [NSArray arrayWithArray:bid] : @[[[PBMORTBBid alloc] init]];
}

- (void)populateJsonDictionary:(PBMMutableJsonDictionary *)jsonDictionary {
    [super populateJsonDictionary:jsonDictionary];
    
    NSMutableArray * const bidsArr = [[NSMutableArray alloc] initWithCapacity:self.bid.count];
    for(PBMORTBSeatBid *nextBid in self.bid) {
        [bidsArr addObject:[nextBid toJsonDictionary]];
    }
    jsonDictionary[@"bid"] = bidsArr;
    
    jsonDictionary[@"seat"] = self.seat;
    jsonDictionary[@"group"] = self.group;
    
    [jsonDictionary pbmRemoveEmptyVals];
}

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary extParser:(id (^)(PBMJsonDictionary *))extParser {
    return (self = [self initWithJsonDictionary:jsonDictionary extParser:extParser bidExtParser:^id (PBMJsonDictionary *d) {
        return nil;
    }]);
}

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary extParser:(id (^)(PBMJsonDictionary *))extParser bidExtParser:(id (^)(PBMJsonDictionary *))bidExtParser {
    if (!(self = [super initWithJsonDictionary:jsonDictionary extParser:extParser])) {
        return nil;
    }
    
    NSArray * const bidsJsonArr = jsonDictionary[@"bid"];
    _bid = nil;
    if (bidsJsonArr) {
        NSMutableArray * const newBid = [[NSMutableArray alloc] initWithCapacity:bidsJsonArr.count];
        for(PBMJsonDictionary *nextDic in bidsJsonArr) {
            PBMORTBBid * const nextBid = [[PBMORTBBid alloc] initWithJsonDictionary:nextDic extParser:bidExtParser];
            if (nextBid) {
                [newBid addObject:nextBid];
            }
        }
        _bid = newBid;
    }
    if (!_bid.count) {
        return nil;
    }
    
    _seat = jsonDictionary[@"seat"];
    _group = jsonDictionary[@"group"];
    
    return self;
}

@end
