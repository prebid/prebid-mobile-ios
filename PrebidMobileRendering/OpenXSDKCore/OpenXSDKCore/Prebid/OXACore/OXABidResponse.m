//
//  OXABidResponse.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABidResponse+Internal.h"
#import "OXABidResponse+Testing.h"
// Exposed objects
#import "OXABid+Internal.h"
// Response
#import "OXMORTBBid.h"
#import "OXMORTBBidResponse+Internal.h"
#import "OXMORTBSeatBid.h"
// Ext data
#import "OXAORTBBidResponseExt.h"
#import "OXAORTBBidExt.h"
// Helpers
#import "OXMConstants.h"



@interface OXABidResponse ()

@property (nonatomic, strong, readwrite, nullable) NSDictionary<NSString *, NSString *> *targetingInfo;

@end



@implementation OXABidResponse

- (instancetype)initWithJsonDictionary:(OXMJsonDictionary *)jsonDictionary {
    OXARawBidResponse *rawResponse = nil;
    rawResponse = [[OXMORTBBidResponse alloc] initWithJsonDictionary:jsonDictionary
                                                           extParser:^id (OXMJsonDictionary *extDic) {
        return [[OXAORTBBidResponseExt alloc] initWithJsonDictionary:extDic];
    } seatBidExtParser:^id _Nullable(OXMJsonDictionary *extDic) {
        return extDic;
    } bidExtParser:^id _Nullable(OXMJsonDictionary *extDic) {
        return [[OXAORTBBidExt alloc] initWithJsonDictionary:extDic];
    }];
    
    return (self = [self initWithRawBidResponse:rawResponse]);
}

- (instancetype)initWithRawBidResponse:(OXARawBidResponse *)rawBidResponse {
    if (!(self = [super init])) {
        return nil;
    }
    
    _rawResponse = rawBidResponse;
    
    NSMutableArray<OXABid *> * allBids = [[NSMutableArray alloc] init];
    NSMutableDictionary<NSString *, NSString *> * const targetingInfo = [[NSMutableDictionary alloc] init];
    OXABid *winningBid = nil;
    for (OXMORTBSeatBid<NSDictionary *, OXAORTBBidExt *> *nextSeatBid in rawBidResponse.seatbid) {
        for (OXMORTBBid<OXAORTBBidExt *> *nextBid in nextSeatBid.bid) {
            OXABid * const bid = [[OXABid alloc] initWithBid:nextBid];
            if (!bid) {
                continue;
            }
            [allBids addObject:bid];
            if (!winningBid && bid.price > 0 && bid.isWinning) {
                winningBid = bid;
            } else if (bid.targetingInfo.count) {
                [targetingInfo addEntriesFromDictionary:bid.targetingInfo];
            }
        }
    }
    if (winningBid.targetingInfo.count) {
        [targetingInfo addEntriesFromDictionary:winningBid.targetingInfo];
    }
    
    _winningBid = winningBid;
    _allBids = allBids;
    _targetingInfo = targetingInfo.count ? targetingInfo : nil;
    
    return self;
}

@end
