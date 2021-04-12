//
//  OXMORTBBidResponse.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBBidResponse.h"
#import "OXMORTBBidResponse+Internal.h"
#import "OXMORTBSeatBid+Internal.h"

#import "OXMORTBSeatBid.h"

@implementation OXMORTBBidResponse

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _requestID = @"";
    return self;
}

- (void)setSeatbid:(NSArray<OXMORTBSeatBid *> *)seatbid {
    _seatbid = seatbid ? [NSArray arrayWithArray:seatbid] : nil;
}

- (void)populateJsonDictionary:(OXMMutableJsonDictionary *)jsonDictionary {
    [super populateJsonDictionary:jsonDictionary];
    
    jsonDictionary[@"id"] = _requestID;
    
    if (self.seatbid) {
        NSMutableArray * const seatbidsArr = [[NSMutableArray alloc] initWithCapacity:self.seatbid.count];
        for(OXMORTBSeatBid *nextSeatBid in self.seatbid) {
            [seatbidsArr addObject:[nextSeatBid toJsonDictionary]];
        }
        jsonDictionary[@"seatbid"] = seatbidsArr;
    }
    
    jsonDictionary[@"bidid"] = self.bidid;
    jsonDictionary[@"cur"] = self.cur;
    jsonDictionary[@"customdata"] = self.customdata;
    jsonDictionary[@"nbr"] = self.nbr;
    
    [jsonDictionary oxmRemoveEmptyVals];
}

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary extParser:(id (^)(OXMJsonDictionary *))extParser {
    id (^dummyParser)(OXMJsonDictionary *) = ^id(OXMJsonDictionary * dic) { return nil; };
    return (self = [self initWithJsonDictionary:jsonDictionary extParser:extParser seatBidExtParser:dummyParser bidExtParser:dummyParser]);
}

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary extParser:(id (^)(OXMJsonDictionary *))extParser seatBidExtParser:(id (^)(OXMJsonDictionary *))seatBidExtParser bidExtParser:(id (^)(OXMJsonDictionary *))bidExtParser {
    if (!(self = [super initWithJsonDictionary:jsonDictionary extParser:extParser])) {
        return nil;
    }
    _requestID = jsonDictionary[@"id"];
    if (!_requestID) {
        return nil;
    }
    
    NSArray * const seatbidsJsonArr = jsonDictionary[@"seatbid"];
    if (seatbidsJsonArr) {
        NSMutableArray * const newSeatbid = [[NSMutableArray alloc] initWithCapacity:seatbidsJsonArr.count];
        for(OXMJsonDictionary *nextDic in seatbidsJsonArr) {
            OXMORTBSeatBid * const nextSeatBid = [[OXMORTBSeatBid alloc] initWithJsonDictionary:nextDic extParser:seatBidExtParser bidExtParser:bidExtParser];
            if (nextSeatBid) {
                [newSeatbid addObject:nextSeatBid];
            }
        }
        _seatbid = newSeatbid;
    }
    _bidid = jsonDictionary[@"bidid"];
    _cur = jsonDictionary[@"cur"];
    _customdata = jsonDictionary[@"customdata"];
    _nbr = jsonDictionary[@"nbr"];
    
    return self;
}

@end
