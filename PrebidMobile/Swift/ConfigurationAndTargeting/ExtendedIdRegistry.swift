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

/// The EID sources of a `Targeting` instance: its static IDs, SharedID, and the providers registered for
/// `PluginCapability.extendedIds`.
///
/// `getAllExtendedIdJSONs(sharedId:)` is called for each bid request. The providers live in
/// `Registries.extendedIds`, which keeps them in registration order and makes a provider active only once
/// its `onRegister()` returns.
final class ExtendedIdRegistry {

    /// Holds the static IDs. It isn't one of the registered providers, so unregistering a provider
    /// can never remove it.
    let staticProvider = StaticExtendedIdProvider()

    /// Returns the static IDs, then `sharedId` if it isn't `nil`, then the IDs of each registered provider
    /// in registration order. Calls `getExtendedIds()` on every provider.
    ///
    /// An ID is skipped if its source is empty, its JSON is empty or can't be encoded, or the `"source"`
    /// in its JSON differs from its `source`. Then a provider's ID whose source is already in the list is
    /// skipped, so the static IDs and SharedID are always sent, and of several providers the first one
    /// registered wins.
    func getAllExtendedIds(sharedId: ExtendedId? = nil) -> [ExtendedId] {
        collectExtendedIds(sharedId: sharedId).map { $0.extendedId }
    }

    /// Returns the JSON of the IDs that `getAllExtendedIds(sharedId:)` returns, as checked when they were
    /// collected, so that each ID's `toJSONDictionary()` is called once per bid request.
    func getAllExtendedIdJSONs(sharedId: ExtendedId? = nil) -> [[String: Any]] {
        collectExtendedIds(sharedId: sharedId).map { $0.json }
    }

    /// Forgets the warnings logged about `provider`, so that they're logged again if it is registered
    /// again.
    static func providerUnregistered(_ provider: any ExtendedIdProvider) {
        providerWarnings.forget(provider.providerInfo)
    }

    // MARK: - Private

    /// An ID that can be sent, with the source and JSON it was checked with.
    private struct CheckedExtendedId {
        let extendedId: ExtendedId
        let source: String
        let json: [String: Any]
    }

    /// Problems with a provider's IDs repeat on every bid request, auto-refresh included, so each one is
    /// usually logged once per registration of the provider.
    private static let providerWarnings = ProviderWarnings()

    private func collectExtendedIds(sharedId: ExtendedId?) -> [CheckedExtendedId] {
        var extendedIds = [CheckedExtendedId]()
        var sources = Set<String>()

        // The static IDs and SharedID are never skipped as duplicates, not even of each other.
        var ownIds = staticProvider.getExtendedIds()
        if let sharedId {
            ownIds.append(sharedId)
        }

        for extendedId in ownIds {
            let origin = extendedId === sharedId ? "in SharedID" : "in the static IDs"
            switch Self.check(extendedId) {
            case .success(let checked):
                extendedIds.append(checked)
                sources.insert(checked.source)
            case .failure(let problem):
                Log.warn(problem.message(origin: origin))
            }
        }

        for provider in Registries.extendedIds.typed.active {
            let info = provider.providerInfo
            let origin = "provided by \(info)"
            for extendedId in provider.getExtendedIds() {
                // An ID that can't be sent must not take its source, or it would block a valid ID with
                // the same source from a provider registered later.
                let checked: CheckedExtendedId
                switch Self.check(extendedId) {
                case .success(let checkedId):
                    checked = checkedId
                case .failure(let problem):
                    Self.providerWarnings.warnOnce(problem.message(origin: origin), about: info)
                    continue
                }

                guard sources.insert(checked.source).inserted else {
                    Self.providerWarnings.warnOnce(
                        "[extendedIds] Skipping the ID from source \(checked.source) \(origin): an ID from this source is already present.",
                        about: info
                    )
                    continue
                }

                extendedIds.append(checked)
            }
        }

        return extendedIds
    }

    private struct Problem: Error {
        /// `nil` when the problem is that the source is empty.
        let source: String?
        let reason: String

        /// `origin` says where the ID came from, e.g. "in the static IDs" or "provided by name/1.0".
        func message(origin: String) -> String {
            guard let source else {
                return "[extendedIds] Skipping an ID \(origin): \(reason)."
            }

            return "[extendedIds] Skipping the ID from source \(source) \(origin): \(reason)."
        }
    }

    /// Returns the ID with the source and JSON it can be sent with, or why it can't be sent. The JSON holds
    /// user identifiers, so the reason never includes it.
    private static func check(_ extendedId: ExtendedId) -> Result<CheckedExtendedId, Problem> {
        // Read once, so the checks, the warning and the duplicate check all use the same value:
        // `ExternalUserId.source` is a `var` the app can change at any time.
        let source = extendedId.source
        guard !source.isEmpty else {
            return .failure(Problem(source: nil, reason: "its source is empty"))
        }

        let json = extendedId.toJSONDictionary()
        guard !json.isEmpty else {
            return .failure(Problem(source: source, reason: "its JSON is empty"))
        }

        // The duplicate check goes by `source`, so a JSON naming another source could add a second ID
        // for a source that is already present.
        guard json["source"] as? String == source else {
            return .failure(Problem(source: source, reason: "the \"source\" in its JSON is different"))
        }

        // Checked one by one, because a single EID that can't be encoded would make the whole bid
        // request fail to encode.
        guard JSONSerialization.isValidJSONObject(json) else {
            return .failure(Problem(source: source, reason: "its JSON can't be encoded"))
        }

        return .success(CheckedExtendedId(extendedId: extendedId, source: source, json: json))
    }
}

/// The warnings already logged about each registered provider.
private final class ProviderWarnings {

    /// Sources come from vendor code, so the messages kept for one provider are bounded.
    private static let maxMessagesPerProvider = 100

    private let lock = NSLock()

    private var logged = [ExtendedIdProviderInfo: Set<String>]()

    func warnOnce(_ message: String, about provider: ExtendedIdProviderInfo) {
        let isNew = lock.withLock { () -> Bool in
            if logged[provider]?.contains(message) == true {
                return false
            }

            if logged[provider]?.count ?? 0 >= Self.maxMessagesPerProvider {
                logged[provider] = nil
            }

            logged[provider, default: []].insert(message)
            return true
        }

        if isNew {
            Log.warn(message)
        }
    }

    /// A request that read the providers before `provider` was unregistered can still add a warning
    /// after this, so then that warning isn't logged again when `provider` is registered again.
    func forget(_ provider: ExtendedIdProviderInfo) {
        lock.withLock {
            logged[provider] = nil
        }
    }
}
