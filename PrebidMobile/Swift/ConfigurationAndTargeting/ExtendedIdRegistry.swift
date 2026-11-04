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
/// `getAllExtendedIds(sharedId:)` is called for each bid request. The providers live in
/// `Registries.extendedIds`, which keeps them in registration order and makes a provider active only once
/// its `onRegister()` returns.
final class ExtendedIdRegistry {

    /// Holds the static IDs. It isn't one of the registered providers, so unregistering a provider
    /// can never remove it.
    let staticProvider = StaticExtendedIdProvider()

    /// Returns the static IDs, then `sharedId` if it isn't `nil`, then the IDs of each registered provider
    /// in registration order. Calls `getExtendedIds()` on every provider.
    ///
    /// A provider's ID whose source is already in the list is skipped, so the static IDs and SharedID are
    /// always sent, and of several providers the first one registered wins.
    func getAllExtendedIds(sharedId: ExtendedId? = nil) -> [ExtendedId] {
        var extendedIds = staticProvider.getExtendedIds()
        if let sharedId {
            extendedIds.append(sharedId)
        }

        var sources = Set(extendedIds.map { $0.source })
        for provider in Registries.extendedIds.typed.active {
            for extendedId in provider.getExtendedIds() {
                guard sources.insert(extendedId.source).inserted else {
                    Log.warn("[extendedIds] Skipping the ID from source \(extendedId.source) provided by \(provider.providerInfo): an ID from this source is already present.")
                    continue
                }

                extendedIds.append(extendedId)
            }
        }

        return extendedIds
    }
}
