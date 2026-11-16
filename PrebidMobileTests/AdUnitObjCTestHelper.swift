/*   Copyright 2018-2019 Prebid.org, Inc.

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

import Foundation
@testable import PrebidMobile

// ObjC name fixed so `AdUnitObjCTests.m` can declare the class itself: it cannot import `PrebidMobileTests-Swift.h`,
// which also lists the Swift mocks that subclass the (internal) SDK classes.
@objc(AdUnitObjCTestHelper) @objcMembers
public class AdUnitObjCTestHelper: NSObject {

    private override init() { }

    /// A banner ad unit whose bid requester answers with a winning bid (`hb_bidder` is `openx`) instead of calling
    /// Prebid Server. ObjC cannot call the internal initializer that takes the bid requester.
    class func adUnitWithWinningBid() -> AdUnit {
        AdUnit(
            bidRequester: MockPBMBidRequester(
                jsonDictionary: BidResponseTransformer.makeValidCachedResponse(bidPrice: 0.75).jsonDict ?? [:]
            ),
            configId: "1001-1",
            size: CGSize(width: 300, height: 250),
            adFormats: [.banner]
        )
    }
}
