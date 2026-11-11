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

/// A plugin that chooses the winning bid of each auction, in place of the SDK's default choice.
/// Register it with `Prebid.register(_:as:)` as `.bidSelector`:
///
/// ```swift
/// final class HighestPriceSelector: NSObject, PrebidBidSelecting {
///
///     let pluginInfo = PrebidPluginInfo(name: "com.example.highest-price", version: "1.0")
///
///     func selectBid(from bids: [Bid], context: BidSelectionContext) -> Bid? {
///         bids.max { $0.price < $1.price }
///     }
/// }
///
/// Prebid.register(HighestPriceSelector(), as: .bidSelector)
/// ```
///
/// A registered selector applies to every ad unit of the Original, Rendering and Mediation APIs. It takes
/// precedence over the default choice, which is the bid that Prebid Server marked as the winner with
/// the `hb_pb` and `hb_bidder` targeting keys, and over `Targeting.forceSdkToChooseWinner`.
///
/// For each auction the SDK:
/// 1. Drops the bids the ad unit can't use. With `Prebid.filterOutUncachedBids`, the Original API drops
///    the bids without a Prebid Cache entry.
/// 2. Calls `selectBid(from:context:)` once, on the main thread, with the remaining bids.
/// 3. Builds the targeting keywords from the selected bid alone: its own keys, plus the generic keys
///    (`hb_pb`, `hb_bidder`, `hb_cache_id`, ...) filled in from its bidder-specific keys when Prebid
///    Server didn't pick it. The SDK adds these keys to the selected bid's `targetingInfo`.
/// 4. Makes the selected bid the winner. If the ad unit sends targeting keywords to an ad server and the
///    selected bid's keywords lack the winner keys, the auction ends with
///    `ResultCode.prebidDemandInvalidTargeting` instead. Ad units that render the bid without an ad
///    server don't need the keywords.
///
/// The selector's decision is final. If it returns `nil`, or an object that isn't one of the bids it was
/// given, the auction has no winner: no targeting keywords are attached and no ad is rendered. The SDK
/// never falls back to its default choice.
///
/// At most one selector is registered at a time.
@objc
public protocol PrebidBidSelecting: AnyObject {

    /// The selector's name and version. The SDK uses it to detect duplicate registrations and in logs.
    /// Must not change for the lifetime of the selector.
    @objc var pluginInfo: PrebidPluginInfo { get }

    /// Returns the winning bid for the ad unit that `context` describes, or `nil` for no winner.
    ///
    /// Called once per auction, on the main thread, so it must return immediately: no network calls,
    /// disk I/O or other blocking work. It must not change the bids or start another auction.
    ///
    /// - Parameters:
    ///   - bids: The bids the ad unit can use. Never empty.
    ///   - context: The ad unit that started the auction.
    /// - Returns: One of the objects in `bids`, or `nil`.
    @objc(selectBidFrom:context:)
    func selectBid(from bids: [Bid], context: BidSelectionContext) -> Bid?

    /// Called once after the selector is registered, before the SDK calls it for an auction.
    @objc optional func onRegister()

    /// Called when the selector is unregistered. Release resources here.
    @objc optional func onUnregister()
}

/// The ad unit whose auction a `PrebidBidSelecting` decides.
@objcMembers
public final class BidSelectionContext: NSObject {

    /// The ad unit's configuration ID (the stored impression ID).
    public let configId: String

    /// The ad formats the ad unit requested.
    public let adFormats: Set<AdFormat>

    init(configId: String, adFormats: Set<AdFormat>) {
        self.configId = configId
        self.adFormats = adFormats

        super.init()
    }
}
