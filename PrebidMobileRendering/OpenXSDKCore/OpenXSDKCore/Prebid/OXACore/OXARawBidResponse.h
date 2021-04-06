//
//  OXARawBidResponse.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

@class OXAORTBBidResponseExt;
@class OXAORTBBidExt;

@class OXMORTBBidResponse<ExtType, SeatBidExtType, BidExtType>;

typedef OXMORTBBidResponse<OXAORTBBidResponseExt *, NSDictionary *, OXAORTBBidExt *> OXARawBidResponse;
