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

import XCTest

@testable import PrebidMobile

class NativeAdExpirationDelegate: NSObject, NativeAdEventDelegate {
    let expireExpectation: XCTestExpectation
    var expireCallCount = 0
    weak var expiredAd: NativeAd?

    init(expireExpectation: XCTestExpectation) {
        self.expireExpectation = expireExpectation
    }

    func adDidExpire(ad: NativeAd) {
        expireCallCount += 1
        expiredAd = ad
        expireExpectation.fulfill()
    }
}
