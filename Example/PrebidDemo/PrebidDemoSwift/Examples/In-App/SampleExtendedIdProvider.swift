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
import PrebidMobile

/// A sample provider of Extended IDs (EIDs).
///
/// A real provider gets its IDs from its own SDK or service, keeps the latest ones, and hands them to
/// Prebid from `getExtendedIds()`. Once it is registered with `Prebid.register(_:as:)` as `.extendedIds`,
/// the SDK adds its IDs to every bid request, after the IDs set through `Targeting`.
final class SampleExtendedIdProvider: NSObject, ExtendedIdProvider {

    static let source = "sample-id-provider.example"

    /// Identifies the provider. Registering a second provider with the same name and version is ignored.
    let providerInfo = ExtendedIdProviderInfo(name: SampleExtendedIdProvider.source, version: "1.0.0")

    // `getExtendedIds()` may be called on any thread, possibly concurrently, so the ID is behind a lock.
    private let lock = NSLock()
    private var userId: String?

    /// Called once inside `Prebid.register(_:as:)`. Start keeping your IDs current here, for example by
    /// listening to your own SDK. This sample makes up an ID instead.
    func onRegister() {
        setUserId(UUID().uuidString)
        PrebidDemoLogger.shared.info("SampleExtendedIdProvider registered")
    }

    /// Called on every bid request, so return the IDs you already have, without network calls or other
    /// blocking work. Return an empty array while you have none.
    func getExtendedIds() -> [ExtendedId] {
        guard let userId = currentUserId() else {
            return []
        }

        // An EID you already have as an OpenRTB dictionary can be returned as `RawExtendedId(json:)`.
        return [
            ExternalUserId(
                source: Self.source,
                // Agent type 1: the ID belongs to this device
                uids: [UserUniqueID(uniqueId: userId, aType: 1)]
            )
        ]
    }

    /// Called inside `Prebid.unregister(_:as:)`. Stop keeping your IDs current here. Bid requests that are
    /// already being built may still call `getExtendedIds()`, so keep it working.
    func onUnregister() {
        PrebidDemoLogger.shared.info("SampleExtendedIdProvider unregistered")
    }

    private func setUserId(_ userId: String) {
        lock.lock()
        defer { lock.unlock() }
        self.userId = userId
    }

    private func currentUserId() -> String? {
        lock.lock()
        defer { lock.unlock() }
        return userId
    }
}
