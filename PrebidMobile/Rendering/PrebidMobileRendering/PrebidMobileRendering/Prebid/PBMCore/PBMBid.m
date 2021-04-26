//
//  PBMBid.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import StoreKit;

#import "PBMBid+Internal.h"

#import "PBMORTBPrebid.h"
#import "PBMORTBMacrosHelper.h"

@implementation PBMBid

- (instancetype)initWithBid:(PBMORTBBid<PBMORTBBidExt *> *)bid {
    if (!(self = [super init])) {
        return nil;
    }
    _bid = bid;
    PBMORTBMacrosHelper * const macrosHelper = [[PBMORTBMacrosHelper alloc] initWithBid:bid];
    _adm = [macrosHelper replaceMacrosInString:bid.adm];
    _nurl = [macrosHelper replaceMacrosInString:bid.nurl];
    // TODO: Replace macros in 'bid.burl', if ever added to public API.
    return self;
}

- (float)price {
    return self.bid.price.floatValue;
}

- (CGSize)size {
    NSNumber * const w = self.bid.w;
    NSNumber * const h = self.bid.h;
    return (w && h) ? CGSizeMake(w.floatValue, h.floatValue) : CGSizeZero;
}

- (NSDictionary<NSString *,NSString *> *)targetingInfo {
    return self.bid.ext.prebid.targeting;
}

- (NSDictionary<NSString *, id> *)skadnInfo {
    if (!self.bid.ext.skadn) {
        return nil;
    } else {
        if (@available(iOS 14.0, *)) {
            PBMORTBBidExtSkadn *skadn = self.bid.ext.skadn;
            return @{
                SKStoreProductParameterITunesItemIdentifier: skadn.itunesitem,
                SKStoreProductParameterAdNetworkIdentifier: skadn.network,
                SKStoreProductParameterAdNetworkCampaignIdentifier: skadn.campaign,
                SKStoreProductParameterAdNetworkTimestamp: skadn.timestamp,
                SKStoreProductParameterAdNetworkNonce: skadn.nonce,
                SKStoreProductParameterAdNetworkAttributionSignature: skadn.signature,
                SKStoreProductParameterAdNetworkSourceAppStoreIdentifier: skadn.sourceapp,
                SKStoreProductParameterAdNetworkVersion: skadn.version
            };
        } else {
            return nil;
        }
    }
}

- (BOOL)isWinning {
    NSDictionary<NSString *, NSString *> * const targetingInfo = self.targetingInfo;
    if (!targetingInfo) {
        return NO;
    }
    for(NSString * markerKey in @[@"hb_pb", @"hb_bidder", @"hb_cache_id"]) {
        if (!targetingInfo[markerKey]) {
            return NO;
        }
    }
    return YES;
}

@end
