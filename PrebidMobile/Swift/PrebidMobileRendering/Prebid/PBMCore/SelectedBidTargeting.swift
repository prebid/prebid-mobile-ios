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

/// Builds the targeting of a bid that a bid selector chose, from that bid alone.
///
/// The result is the bid's own keys plus the generic keys (`hb_pb`, `hb_bidder`, `hb_cache_id`, ...)
/// that Prebid Server sets only on the winner it picked. A generic key the bid lacks is filled in from
/// the bid's bidder-specific form of it, e.g. `hb_pb` from `hb_pb_appnexus`, so the price bucket is the
/// one Prebid Server computed. A key the bid has in neither form is left out. No value ever comes from
/// another bid.
///
/// The bidder code (the key suffix) is the value of the bid's `hb_bidder` or `hb_bidder_<code>` key, so a
/// bidder alias resolves to its own keys. A bidder-specific key may be truncated by Prebid Server.
enum SelectedBidTargeting {

    enum Failure: Error, Equatable {

        /// The bid's `hb_bidder_<code>` keys name more than one bidder.
        case ambiguousBidder(codes: [String])

        /// More than one of the bid's keys can be the truncated bidder-specific form of `key`.
        case ambiguousKey(String, candidates: [String])

        var message: String {
            switch self {
            case .ambiguousBidder(let codes):
                return "the bid names more than one bidder: \(codes.joined(separator: ", "))"
            case .ambiguousKey(let key, let candidates):
                return "more than one key of the bid can be \(key): \(candidates.joined(separator: ", "))"
            }
        }
    }

    static func make(from targeting: [String: String]) -> Result<[String: String], Failure> {
        var result = targeting

        let bidderCode: String
        if let code = targeting[TargetingKey.bidder] {
            bidderCode = code
        } else {
            let codes = Set(targeting.compactMap { key, value in
                isBidderSpecificForm(key, of: TargetingKey.bidder, bidderCode: value) ? value : nil
            })

            guard codes.count <= 1 else {
                return .failure(.ambiguousBidder(codes: codes.sorted()))
            }

            guard let code = codes.first else {
                // Without a bidder code there is no bidder-specific key to read
                return .success(targeting)
            }

            bidderCode = code
            result[TargetingKey.bidder] = code
        }

        for key in TargetingKey.selectedBidKeys where targeting[key] == nil {
            if let value = targeting["\(key)_\(bidderCode)"] {
                result[key] = value
                continue
            }

            let truncatedForms = targeting.keys.filter {
                isBidderSpecificForm($0, of: key, bidderCode: bidderCode)
            }

            guard truncatedForms.count <= 1 else {
                return .failure(.ambiguousKey(key, candidates: truncatedForms.sorted()))
            }

            if let truncatedForm = truncatedForms.first {
                result[key] = targeting[truncatedForm]
            }
        }

        return .success(result)
    }

    /// Whether `candidate` is the bidder-specific form of `key` for `bidderCode`: `<key>_<bidderCode>`,
    /// or that key truncated, but never shorter than `<key>_` plus one character.
    static func isBidderSpecificForm(_ candidate: String, of key: String, bidderCode: String) -> Bool {
        let prefix = key + "_"

        return candidate.count > prefix.count
            && candidate.hasPrefix(prefix)
            && (prefix + bidderCode).hasPrefix(candidate)
    }
}
