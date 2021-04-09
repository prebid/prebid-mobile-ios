//
//  OXMORTBSeatBid.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXMORTBAbstractResponse.h"

@class OXMORTBBid<ExtType>;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 4.2.2: SeatBid

/// A bid response can contain multiple `SeatBid` objects, each on behalf of a different bidder seat and each containing
/// one or more individual bids. If multiple impressions are presented in the request, the `group` attribute can be used to
/// specify if a seat is willing to accept any impressions that it can win (default) or if it is only interested in
/// winning any if it can win them all as a group.
@interface OXMORTBSeatBid<__covariant ExtType, __covariant BidExtType> : OXMORTBAbstractResponse<ExtType>

/// [Required]
/// Array of 1+ `Bid` objects (Section 4.2.3) each related to an impression. Multiple bids can relate to the same impression.
@property (nonatomic, copy) NSArray<OXMORTBBid<BidExtType> *> *bid;

/// ID of the buyer seat (e.g., advertiser, agency) on whose behalf this bid is made.
@property (nonatomic, copy, nullable) NSString *seat;

/// [Integer]
/// [Default = 0]
/// 0 = impressions can be won individually; 1 = impressions must be won or lost as a group.
@property (nonatomic, strong, nullable) NSNumber *group;

// Placeholder for bidder-specific extensions to OpenRTB.
// ext is stored in superclass

@end

NS_ASSUME_NONNULL_END
