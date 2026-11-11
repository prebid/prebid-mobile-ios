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

import Foundation

/// The Prebid targeting keys that Prebid Server sets on a bid's `ext.prebid.targeting`.
///
/// Prebid Server sends the generic form (e.g. `hb_pb`) only for the winning bid of an impression, and
/// the bidder-specific form (e.g. `hb_pb_appnexus`) for every bid. It may truncate the bidder-specific
/// form to its key length limit (20 characters by default), e.g. `hb_cache_host_appnex`.
enum TargetingKey {

    /// The price bucket.
    static let price = "hb_pb"

    /// The bidder code. Its bidder-specific form also gives the suffix of every other bidder-specific key.
    static let bidder = "hb_bidder"

    static let size = "hb_size"
    static let format = "hb_format"
    static let deal = "hb_deal"

    /// The Prebid Cache ID of the whole bid.
    static let cacheId = "hb_cache_id"

    /// The Prebid Cache ID of the VAST XML.
    static let vastCacheId = "hb_uuid"

    static let cacheHost = "hb_cache_host"
    static let cachePath = "hb_cache_path"
    static let environment = "hb_env"

    /// The keys that make a bid the winner of its impression (see `Bid.isWinning`).
    static var winningBidMarkers: [String] {
        var markers = [price, bidder]

        if Prebid.shared.useCacheForReportingWithRenderingAPI {
            markers.append(cacheId)
        }

        return markers
    }

    /// The generic keys the SDK fills in for a bid chosen by a bid selector, from that bid's own
    /// bidder-specific keys. `bidder` is resolved first, so it isn't listed here.
    static let selectedBidKeys = [
        price,
        size,
        format,
        deal,
        cacheId,
        vastCacheId,
        cacheHost,
        cachePath,
        environment,
    ]
}
