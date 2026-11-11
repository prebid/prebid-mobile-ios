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

// A plain Objective-C bid selector, proving that apps written in Objective-C can implement and register one.
@interface ObjCHighestPriceBidSelector : NSObject <PrebidBidSelecting>

@property (nonatomic, assign) NSInteger registerCount;
@property (nonatomic, assign) NSInteger unregisterCount;

@end

@implementation ObjCHighestPriceBidSelector

- (PrebidPluginInfo *)pluginInfo {
    return [[PrebidPluginInfo alloc] initWithName:@"com.example.objc-selector" version:@"1.0"];
}

- (Bid * _Nullable)selectBidFrom:(NSArray<Bid *> * _Nonnull)bids context:(BidSelectionContext * _Nonnull)context {
    Bid *best = nil;
    for (Bid *bid in bids) {
        if (best == nil || bid.price > best.price) {
            best = bid;
        }
    }
    return best;
}

- (void)onRegister {
    self.registerCount += 1;
}

- (void)onUnregister {
    self.unregisterCount += 1;
}

@end

@interface PrebidBidSelectingObjCTest : XCTestCase
@end

@implementation PrebidBidSelectingObjCTest

- (void)testRegisterAndUnregisterFromObjC {
    ObjCHighestPriceBidSelector *selector = [[ObjCHighestPriceBidSelector alloc] init];

    [Prebid registerPlugin:selector as:PluginCapability.bidSelector];

    XCTAssertTrue([Prebid containsPlugin:selector as:PluginCapability.bidSelector]);
    XCTAssertEqual(selector.registerCount, 1);

    [Prebid unregisterPlugin:selector as:PluginCapability.bidSelector];

    XCTAssertFalse([Prebid containsPlugin:selector as:PluginCapability.bidSelector]);
    XCTAssertEqual(selector.unregisterCount, 1);
}

- (void)testCapabilityAndResultCodeAreVisibleFromObjC {
    XCTAssertEqualObjects(PluginCapability.bidSelector.name, @"bidSelector");
    XCTAssertEqual(ResultCodePrebidDemandInvalidTargeting, 12);
}

@end
