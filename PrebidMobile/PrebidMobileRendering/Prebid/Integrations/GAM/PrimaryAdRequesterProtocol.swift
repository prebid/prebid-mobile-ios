//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

@objc(PBMPrimaryAdRequesterProtocol)
public protocol PrimaryAdRequesterProtocol: NSObjectProtocol {
    
    /**
     @abstract PBM SDK calls this method when it has valid bid/s to pass to the ad server.
     @discussion Note that, if the PBM SDK does not have valid bids, `requestAdWithBidResponse:` will be called with a `nil` bid value.
     @param bidResponse bid response object having useful information that can be passed to the ad server SDK
     */
    @objc(requestAdWithBidResponse:)
    func requestAd(with bidResponse: BidResponse?)
}
