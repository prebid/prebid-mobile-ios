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

/// A source of Extended IDs (EIDs) for OpenRTB bid requests.
///
/// The SDK calls `getExtendedIds()` on every bid request, so the IDs it sends always reflect the
/// provider's current state (consent, session changes, refreshed tokens). IDs may be resolved
/// synchronously or asynchronously, but `getExtendedIds()` itself must not block: it runs while the
/// bid request is built, on the thread that started the ad load (often the main thread).
///
/// Lifecycle:
/// 1. `onRegister()` is called once after `Prebid.registerExtendedIdProvider(_:)`, before the
///    provider's IDs are included in bid requests.
/// 2. `getExtendedIds()` is called on every bid request.
/// 3. `onUnregister()` is called after `Prebid.unregisterExtendedIdProvider(_:)`.
///
/// ```swift
/// final class MyIdProvider: NSObject, ExtendedIdProvider {
///
///     let providerInfo = ExtendedIdProviderInfo(name: "my-source.com", version: "1.0")
///
///     func getExtendedIds() -> [ExtendedId] {
///         guard let id = resolvedId else { return [] }
///         return [ExternalUserId(source: "my-source.com", uids: [UserUniqueID(uniqueId: id, aType: 1)])]
///     }
/// }
/// ```
@objc
public protocol ExtendedIdProvider: AnyObject {

    /// The provider's name and version. The SDK uses it to detect duplicate registrations and in logs.
    /// Must not change for the lifetime of the provider.
    @objc var providerInfo: ExtendedIdProviderInfo { get }

    /// Returns the provider's current EIDs. May be empty.
    ///
    /// Called on every bid request, so it must return immediately: no network calls, disk I/O,
    /// or other blocking work.
    @objc func getExtendedIds() -> [ExtendedId]

    /// Called once after the provider is registered, before its IDs are included in bid requests.
    @objc optional func onRegister()

    /// Called when the provider is unregistered. Release resources here.
    @objc optional func onUnregister()
}

/// Identity of an `ExtendedIdProvider`: its `name` and `version`.
///
/// Two providers with equal info (both `name` and `version` match) are treated as the same provider:
/// registering the second one is ignored, and unregistering either of them removes the registered one.
/// Choose a `name` specific to your integration (e.g. your source domain) so it doesn't collide with
/// other vendors.
@objcMembers
public final class ExtendedIdProviderInfo: NSObject {

    /// The provider name.
    public let name: String

    /// The provider version.
    public let version: String

    public init(name: String, version: String) {
        self.name = name
        self.version = version

        super.init()
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ExtendedIdProviderInfo else {
            return false
        }

        return name == other.name && version == other.version
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(name)
        hasher.combine(version)
        return hasher.finalize()
    }

    public override var description: String {
        "\(name)/\(version)"
    }
}
