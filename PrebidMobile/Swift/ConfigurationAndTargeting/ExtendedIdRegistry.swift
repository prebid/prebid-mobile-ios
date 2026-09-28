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

/// Thread-safe store of the EID sources of a `Targeting` instance: the static IDs set through
/// `Targeting` and the registered `ExtendedIdProvider`s.
///
/// `getAllExtendedIds()` collects the EIDs of every source and is called for each bid request.
/// Provider code (`onRegister()`, `getExtendedIds()`, `onUnregister()`) always runs outside the lock,
/// so a provider may call back into the registry.
final class ExtendedIdRegistry {

    /// Holds the static IDs. It isn't one of the registered providers, so unregistering a provider
    /// can never remove it.
    let staticProvider = StaticExtendedIdProvider()

    private final class Registration {
        let info: ExtendedIdProviderInfo
        let provider: ExtendedIdProvider

        /// Set once `onRegister()` returns. Until then the provider's IDs aren't collected.
        var isActive = false

        init(info: ExtendedIdProviderInfo, provider: ExtendedIdProvider) {
            self.info = info
            self.provider = provider
        }
    }

    private let lock = NSLock()
    private var registrations = [Registration]()

    /// Returns the static IDs, then the IDs of each registered provider in registration order.
    /// Calls `getExtendedIds()` on every provider.
    func getAllExtendedIds() -> [ExtendedId] {
        let providers = synchronized {
            registrations.filter { $0.isActive }.map { $0.provider }
        }

        return staticProvider.getExtendedIds() + providers.flatMap { $0.getExtendedIds() }
    }

    /// Registers `provider` and calls its `onRegister()`. Its IDs are collected once `onRegister()`
    /// returns. A provider whose info equals a registered one is ignored.
    func addProvider(_ provider: ExtendedIdProvider) {
        let info = provider.providerInfo
        let registration = Registration(info: info, provider: provider)

        let isAdded = synchronized { () -> Bool in
            guard !registrations.contains(where: { $0.info == info }) else {
                return false
            }

            registrations.append(registration)
            return true
        }

        guard isAdded else {
            Log.warn("Extended ID provider \(info) is already registered. Ignoring the duplicate.")
            return
        }

        provider.onRegister?()
        synchronized { registration.isActive = true }
        Log.debug("Extended ID provider \(info) registered.")
    }

    /// Unregisters the provider whose info equals `provider`'s and calls that provider's `onUnregister()`.
    /// No-op if no such provider is registered.
    func removeProvider(_ provider: ExtendedIdProvider) {
        let info = provider.providerInfo

        let removed = synchronized { () -> Registration? in
            guard let index = registrations.firstIndex(where: { $0.info == info }) else {
                return nil
            }

            return registrations.remove(at: index)
        }

        guard let removed else {
            return
        }

        removed.provider.onUnregister?()
        Log.debug("Extended ID provider \(info) unregistered.")
    }

    /// Returns whether a provider whose info equals `provider`'s is registered.
    func hasProvider(_ provider: ExtendedIdProvider) -> Bool {
        let info = provider.providerInfo
        return synchronized {
            registrations.contains { $0.info == info }
        }
    }

    /// Unregisters every provider, calling `onUnregister()` on each, and clears the static IDs.
    func clearProviders() {
        let removed = synchronized { () -> [Registration] in
            let removed = registrations
            registrations.removeAll()
            return removed
        }

        staticProvider.clear()
        removed.forEach { $0.provider.onUnregister?() }
    }

    private func synchronized<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
