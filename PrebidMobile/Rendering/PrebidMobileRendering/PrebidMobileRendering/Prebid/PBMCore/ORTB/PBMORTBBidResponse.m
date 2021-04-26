//
//  PBMORTBBidResponse.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMORTBBidResponse.h"
#import "PBMORTBBidResponse+Internal.h"
#import "PBMORTBSeatBid+Internal.h"

#import "PBMORTBSeatBid.h"

@implementation PBMORTBBidResponse

- (instancetype)init {
    if (!(self = [super init])) {
        return nil;
    }
    _requestID = @"";
    return self;
}

- (void)setSeatbid:(NSArray<PBMORTBSeatBid *> *)seatbid {
    _seatbid = seatbid ? [NSArray arrayWithArray:seatbid] : nil;
}

- (void)populateJsonDictionary:(PBMMutableJsonDictionary *)jsonDictionary {
    [super populateJsonDictionary:jsonDictionary];
    
    jsonDictionary[@"id"] = _requestID;
    
    if (self.seatbid) {
        NSMutableArray * const seatbidsArr = [[NSMutableArray alloc] initWithCapacity:self.seatbid.count];
        for(PBMORTBSeatBid *nextSeatBid in self.seatbid) {
            [seatbidsArr addObject:[nextSeatBid toJsonDictionary]];
        }
        jsonDictionary[@"seatbid"] = seatbidsArr;
    }
    
    jsonDictionary[@"bidid"] = self.bidid;
    jsonDictionary[@"cur"] = self.cur;
    jsonDictionary[@"customdata"] = self.customdata;
    jsonDictionary[@"nbr"] = self.nbr;
    
    [jsonDictionary pbmRemoveEmptyVals];
}

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary extParser:(id (^)(PBMJsonDictionary *))extParser {
    id (^dummyParser)(PBMJsonDictionary *) = ^id(PBMJsonDictionary * dic) { return nil; };
    return (self = [self initWithJsonDictionary:jsonDictionary extParser:extParser seatBidExtParser:dummyParser bidExtParser:dummyParser]);
}

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary extParser:(id (^)(PBMJsonDictionary *))extParser seatBidExtParser:(id (^)(PBMJsonDictionary *))seatBidExtParser bidExtParser:(id (^)(PBMJsonDictionary *))bidExtParser {
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
        for(PBMJsonDictionary *nextDic in seatbidsJsonArr) {
            PBMORTBSeatBid * const nextSeatBid = [[PBMORTBSeatBid alloc] initWithJsonDictionary:nextDic extParser:seatBidExtParser bidExtParser:bidExtParser];
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
