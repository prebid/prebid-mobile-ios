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
    /// An ID whose JSON is empty or can't be encoded is skipped. Then a provider's ID whose source is
    /// already in the list is skipped, so the static IDs and SharedID are always sent, and of several
    /// providers the first one registered wins.
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

    /// An ID that can be sent, with the JSON it was checked with.
    private struct CheckedExtendedId {
        let extendedId: ExtendedId
        let json: [String: Any]
    }

    /// Problems with a provider's IDs repeat on every bid request, auto-refresh included, so each one is
    /// logged once per registration of the provider.
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
            let isSharedId = extendedId === sharedId
            let origin = isSharedId ? "SharedID" : "the static IDs"
            switch Self.check(extendedId) {
            case .success(let json):
                extendedIds.append(CheckedExtendedId(extendedId: extendedId, json: json))
                sources.insert(extendedId.source)
            case .failure(let problem):
                Log.warn("[extendedIds] Skipping the ID from source \(extendedId.source) in \(origin): \(problem.reason).")
            }
        }

        for provider in Registries.extendedIds.typed.active {
            for extendedId in provider.getExtendedIds() {
                // An ID that can't be sent must not take its source, or it would block a valid ID with
                // the same source from a provider registered later.
                let json: [String: Any]
                switch Self.check(extendedId) {
                case .success(let checkedJSON):
                    json = checkedJSON
                case .failure(let problem):
                    Self.providerWarnings.warnOnce(
                        "[extendedIds] Skipping the ID from source \(extendedId.source) provided by \(provider.providerInfo): \(problem.reason).",
                        about: provider.providerInfo
                    )
                    continue
                }

                guard sources.insert(extendedId.source).inserted else {
                    Self.providerWarnings.warnOnce(
                        "[extendedIds] Skipping the ID from source \(extendedId.source) provided by \(provider.providerInfo): an ID from this source is already present.",
                        about: provider.providerInfo
                    )
                    continue
                }

                extendedIds.append(CheckedExtendedId(extendedId: extendedId, json: json))
            }
        }

        return extendedIds
    }

    private struct Problem: Error {
        let reason: String
    }

    /// Returns the JSON of `extendedId`, or why it can't be sent. The JSON holds user identifiers, so the
    /// reason never includes it.
    private static func check(_ extendedId: ExtendedId) -> Result<[String: Any], Problem> {
        let json = extendedId.toJSONDictionary()
        guard !json.isEmpty else {
            return .failure(Problem(reason: "its JSON is empty"))
        }

        // Checked one by one, because a single EID that can't be encoded would make the whole bid
        // request fail to encode.
        guard JSONSerialization.isValidJSONObject(json) else {
            return .failure(Problem(reason: "its JSON can't be encoded"))
        }

        return .success(json)
    }
}

/// The warnings already logged about each registered provider.
private final class ProviderWarnings {

    private let lock = NSLock()

    private var logged = [ExtendedIdProviderInfo: Set<String>]()

    func warnOnce(_ message: String, about provider: ExtendedIdProviderInfo) {
        let isNew = lock.withLock {
            logged[provider, default: []].insert(message).inserted
        }

        if isNew {
            Log.warn(message)
        }
    }

    func forget(_ provider: ExtendedIdProviderInfo) {
        lock.withLock {
            logged[provider] = nil
        }
    }
}
