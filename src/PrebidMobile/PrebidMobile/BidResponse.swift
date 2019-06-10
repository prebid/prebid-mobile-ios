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

private let kDefaultBidExpiryTime: TimeInterval = 270

class BidResponse: NSObject {

    /**
     * the adUnitId is the adUnit identifier that the bid response corresponds to
     */
    private(set) var adUnitId: String = ""

    var myUnitId: String? = "" {
        didSet {
            adUnitId = myUnitId!
        }
    }
    /**
     * customKeywords is a dictionary of all the response objects returned by the demand source that can be used in future
     */
    private(set) var customKeywords: [String: String] = [:]

    private var myCustomKeywords: [String: String] = [:] {
        didSet {
            customKeywords = myCustomKeywords
        }
    }

    init(adId: String, adServerTargeting: [String: AnyObject]) {
        super.init()
        adUnitId = adId
        setMyCustomKeywords(newValue: adServerTargeting as! [String: String])

    }

    func setMyCustomKeywords(newValue: [String: String]) {
        self.myCustomKeywords = newValue
    }

}
