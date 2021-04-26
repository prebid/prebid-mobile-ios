//
//  PBMBidResponse.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBidResponse+Internal.h"
#import "PBMBidResponse+Testing.h"
// Exposed objects
#import "PBMBid+Internal.h"
// Response
#import "PBMORTBBid.h"
#import "PBMORTBBidResponse+Internal.h"
#import "PBMORTBSeatBid.h"
// Ext data
#import "PBMORTBBidResponseExt.h"
#import "PBMORTBBidExt.h"
// Helpers
#import "PBMConstants.h"



@interface PBMBidResponse ()

@property (nonatomic, strong, readwrite, nullable) NSDictionary<NSString *, NSString *> *targetingInfo;

@end



@implementation PBMBidResponse

- (instancetype)initWithJsonDictionary:(PBMJsonDictionary *)jsonDictionary {
    PBMRawBidResponse *rawResponse = nil;
    rawResponse = [[PBMORTBBidResponse alloc] initWithJsonDictionary:jsonDictionary
                                                           extParser:^id (PBMJsonDictionary *extDic) {
        return [[PBMORTBBidResponseExt alloc] initWithJsonDictionary:extDic];
    } seatBidExtParser:^id _Nullable(PBMJsonDictionary *extDic) {
        return extDic;
    } bidExtParser:^id _Nullable(PBMJsonDictionary *extDic) {
        return [[PBMORTBBidExt alloc] initWithJsonDictionary:extDic];
    }];
    
    return (self = [self initWithRawBidResponse:rawResponse]);
}

- (instancetype)initWithRawBidResponse:(PBMRawBidResponse *)rawBidResponse {
    if (!(self = [super init])) {
        return nil;
    }
    
    _rawResponse = rawBidResponse;
    
    NSMutableArray<PBMBid *> * allBids = [[NSMutableArray alloc] init];
    NSMutableDictionary<NSString *, NSString *> * const targetingInfo = [[NSMutableDictionary alloc] init];
    PBMBid *winningBid = nil;
    for (PBMORTBSeatBid<NSDictionary *, PBMORTBBidExt *> *nextSeatBid in rawBidResponse.seatbid) {
        for (PBMORTBBid<PBMORTBBidExt *> *nextBid in nextSeatBid.bid) {
            PBMBid * const bid = [[PBMBid alloc] initWithBid:nextBid];
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
