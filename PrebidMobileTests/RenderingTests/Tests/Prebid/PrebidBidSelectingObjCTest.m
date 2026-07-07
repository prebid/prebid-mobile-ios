/*   Copyright 2018-2026 Prebid.org, Inc.

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

#import <XCTest/XCTest.h>
#import "SwiftImport.h"

// A plain Objective-C class adopting PrebidBidSelecting, proving the @objc protocol
// is usable from Objective-C, not just declarable there.
@interface ObjCHighestPriceBidSelector : NSObject <PrebidBidSelecting>
@end

@implementation ObjCHighestPriceBidSelector

- (Bid * _Nullable)selectBidFrom:(NSArray<Bid *> * _Nonnull)bids {
    Bid *best = nil;
    for (Bid *bid in bids) {
        if (best == nil || bid.price > best.price) {
            best = bid;
        }
    }
    return best;
}

@end

@interface PrebidBidSelectingObjCTest : XCTestCase
@end

@implementation PrebidBidSelectingObjCTest

- (void)setUp {
    // Hermetic regardless of what other test suites leave in the shared singleton --
    // isWinning's marker set only includes hb_cache_id when this is true, and these
    // fixtures deliberately don't set that marker.
    Prebid.shared.useCacheForReportingWithRenderingAPI = NO;
}

- (void)testAdoptableAndSettableFromObjC {
    ObjCHighestPriceBidSelector *selector = [[ObjCHighestPriceBidSelector alloc] init];

    AdUnitConfig *config = [[AdUnitConfig alloc] initWithConfigId:@"test-config-id"];
    config.bidSelector = selector;

    XCTAssertEqualObjects(config.bidSelector, selector);
}

- (void)testSelectBidCallableFromObjC {
    ObjCHighestPriceBidSelector *selector = [[ObjCHighestPriceBidSelector alloc] init];

    NSDictionary *markedBid = @{
        @"id": @"marked-bid",
        @"impid": @"imp-1",
        @"price": @0.75,
        @"adm": @"<html></html>",
        @"w": @300,
        @"h": @250,
        @"ext": @{
            @"prebid": @{
                @"targeting": @{@"hb_bidder": @"openx", @"hb_pb": @"0.75"},
                @"type": @"banner"
            }
        }
    };
    NSDictionary *unmarkedBid = @{
        @"id": @"unmarked-bid",
        @"impid": @"imp-2",
        @"price": @2.00,
        @"adm": @"<html></html>",
        @"w": @300,
        @"h": @250,
        @"ext": @{
            @"prebid": @{
                @"type": @"banner"
            }
        }
    };
    NSDictionary *responseDict = @{
        @"id": @"response-id",
        @"seatbid": @[
            @{
                @"bid": @[markedBid, unmarkedBid],
                @"seat": @"openx"
            }
        ],
        @"cur": @"USD"
    };

    BidResponse *bidResponse = [[BidResponse alloc] initWithJsonDictionary:responseDict];

    // Default (no selector): the marker-driven bid wins.
    XCTAssertEqualWithAccuracy(bidResponse.winningBid.price, 0.75, 0.001);

    [bidResponse applyBidSelector:selector];

    // Once the ObjC-adopted selector is applied, the highest-price (unmarked) bid wins instead --
    // proving the protocol method is actually invoked, not just adoptable.
    XCTAssertEqualObjects(bidResponse.bidSelector, selector);
    XCTAssertEqualWithAccuracy(bidResponse.winningBid.price, 2.00, 0.001);
}

@end
