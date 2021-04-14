//
//  OXMORTBSeatBid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBSeatBid.h"
#import "OXMORTBSeatBid+Internal.h"

#import "OXMORTBBid.h"

@implementation OXMORTBSeatBid

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _bid = @[[[OXMORTBBid alloc] init]];
    return self;
}

- (void)setBid:(NSArray<OXMORTBBid *> *)bid {
    BOOL hasBids = NO;
    for(OXMORTBBid *nextBid in bid) {
        if (nextBid) {
            hasBids = YES;
            break;
        }
    }
    _bid = hasBids ? [NSArray arrayWithArray:bid] : @[[[OXMORTBBid alloc] init]];
}

- (void)populateJsonDictionary:(OXMMutableJsonDictionary *)jsonDictionary {
    [super populateJsonDictionary:jsonDictionary];
    
    NSMutableArray * const bidsArr = [[NSMutableArray alloc] initWithCapacity:self.bid.count];
    for(OXMORTBSeatBid *nextBid in self.bid) {
        [bidsArr addObject:[nextBid toJsonDictionary]];
    }
    jsonDictionary[@"bid"] = bidsArr;
    
    jsonDictionary[@"seat"] = self.seat;
    jsonDictionary[@"group"] = self.group;
    
    [jsonDictionary oxmRemoveEmptyVals];
}

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary extParser:(id (^)(OXMJsonDictionary *))extParser {
    return (self = [self initWithJsonDictionary:jsonDictionary extParser:extParser bidExtParser:^id (OXMJsonDictionary *d) {
        return nil;
    }]);
}

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary extParser:(id (^)(OXMJsonDictionary *))extParser bidExtParser:(id (^)(OXMJsonDictionary *))bidExtParser {
    if (!(self = [super initWithJsonDictionary:jsonDictionary extParser:extParser])) {
        return nil;
    }
    
    NSArray * const bidsJsonArr = jsonDictionary[@"bid"];
    _bid = nil;
    if (bidsJsonArr) {
        NSMutableArray * const newBid = [[NSMutableArray alloc] initWithCapacity:bidsJsonArr.count];
        for(OXMJsonDictionary *nextDic in bidsJsonArr) {
            OXMORTBBid * const nextBid = [[OXMORTBBid alloc] initWithJsonDictionary:nextDic extParser:bidExtParser];
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
