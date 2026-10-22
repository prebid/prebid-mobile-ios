/*   Copyright 2018-2025 Prebid.org, Inc.

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

/// A publisher-supplied strategy for choosing the winning bid out of the bids returned by Prebid Server.
///
/// When set, `selectBid(from:)` takes precedence over the SDK's default winner selection
/// (based on the `hb_pb`/`hb_bidder` targeting markers) and over `Targeting.forceSdkToChooseWinner`.
@objc public protocol PrebidBidSelecting: AnyObject {

    /// Selects the winning bid from the given bids, or `nil` if none should win.
    ///
    /// Returning `nil` is final: no bid's targeting keywords are attached to the ad object and
    /// no ad is rendered, regardless of `Targeting.forceSdkToChooseWinner`. The returned bid must
    /// be one of the bids passed in; any other value is treated as `nil`.
    /// - Parameter bids: All bids returned for the request.
    func selectBid(from bids: [Bid]) -> Bid?
}
