/*   Copyright 2018-2023 Prebid.org, Inc.

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
@_spi(PBMInternal) @testable import PrebidMobile

class MockPBMBidRequester: NSObject, BidRequesterProtocol {
    
    let jsonDictionary: [String : Any]
    
    init(jsonDictionary: [String : Any]) {
        self.jsonDictionary = jsonDictionary
    }
    
    func requestBids(completion: @escaping (BidResponse?, Error?) -> Void) {
        let bidResponse = BidResponse(jsonDictionary: jsonDictionary)
        completion(bidResponse, nil)
    }
}

/// A bid requester that answers only when the test says so. Like `BidRequesterImpl`, it runs one request
/// at a time and fails another one at once with `requestInProgress`.
class MockDeferredBidRequester: NSObject, BidRequesterProtocol {
    
    private var pendingCompletion: ((BidResponse?, Error?) -> Void)?

    var hasPendingRequest: Bool {
        pendingCompletion != nil
    }

    func requestBids(completion: @escaping (BidResponse?, Error?) -> Void) {
        guard pendingCompletion == nil else {
            completion(nil, PBMError.requestInProgress())
            return
        }
        
        pendingCompletion = completion
    }
    
    /// Answers the request that is still out.
    func respond(with bidResponse: BidResponse?, error: Error?) {
        let completion = pendingCompletion
        pendingCompletion = nil
        completion?(bidResponse, error)
    }
}
