//
//  PBMRawBidResponse.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

@class PBMORTBBidResponseExt;
@class PBMORTBBidExt;

@class PBMORTBBidResponse<ExtType, SeatBidExtType, BidExtType>;

typedef PBMORTBBidResponse<PBMORTBBidResponseExt *, NSDictionary *, PBMORTBBidExt *> PBMRawBidResponse;
@compatibility_alias RawBidResponse PBMRawBidResponse;
