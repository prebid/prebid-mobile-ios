/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMORTBAbstractResponse.h"

@class PBMORTBBid<ExtType>;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 4.2.2: SeatBid

/// A bid response can contain multiple `SeatBid` objects, each on behalf of a different bidder seat and each containing
/// one or more individual bids. If multiple impressions are presented in the request, the `group` attribute can be used to
/// specify if a seat is willing to accept any impressions that it can win (default) or if it is only interested in
/// winning any if it can win them all as a group.
@interface PBMORTBSeatBid<__covariant ExtType, __covariant BidExtType> : PBMORTBAbstractResponse<ExtType>

/// [Required]
/// Array of 1+ `Bid` objects (Section 4.2.3) each related to an impression. Multiple bids can relate to the same impression.
@property (nonatomic, copy) NSArray<PBMORTBBid<BidExtType> *> *bid;

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
