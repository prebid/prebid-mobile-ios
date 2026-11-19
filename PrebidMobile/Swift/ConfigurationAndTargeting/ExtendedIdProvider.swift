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

/// A source of Extended IDs (EIDs) for OpenRTB bid requests. Register it with `Prebid.register(_:as:)`
/// as `.extendedIds`.
///
/// The SDK calls `getExtendedIds()` on every bid request, so the IDs it sends always reflect the
/// provider's current state (consent, session changes, refreshed tokens). IDs may be resolved
/// synchronously or asynchronously, but `getExtendedIds()` itself must not block, and it may be called
/// on any thread.
///
/// Provider IDs are sent after the static IDs set through `Targeting` and SharedID, in the order the
/// providers were registered. Registration order is the only ordering guarantee. An ID is skipped if its
/// source is empty, its JSON is empty or can't be encoded, or the `"source"` in its JSON differs from its
/// `source`, and so is an ID whose source is already present (a static ID, SharedID, or an ID from a
/// provider registered earlier). The SDK logs a warning for each skipped ID, usually once per
/// registration of the provider.
///
/// Lifecycle:
/// 1. `onRegister()` runs synchronously inside `Prebid.register(_:as:)`, once per registration. The
///    provider's IDs are used only after it returns.
/// 2. `getExtendedIds()` is called for every bid request, on any thread, possibly concurrently.
/// 3. `onUnregister()` runs inside `Prebid.unregister(_:as:)`. Requests already being built may still
///    call `getExtendedIds()` during or after it, so keep it safe to call (e.g. return an empty array).
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
///
/// Prebid.register(MyIdProvider(), as: .extendedIds)
/// ```
@objc
public protocol ExtendedIdProvider: AnyObject {

    /// The provider's name and version. The SDK uses it to detect duplicate registrations and in logs.
    /// Must not change for the lifetime of the provider.
    @objc var providerInfo: ExtendedIdProviderInfo { get }

    /// Returns the provider's current EIDs. May be empty.
    ///
    /// Called on every bid request, so it must return immediately: no network calls, disk I/O,
    /// or other blocking work. May be called on any thread, possibly concurrently.
    @objc func getExtendedIds() -> [ExtendedId]

    /// Called synchronously inside `Prebid.register(_:as:)`, once per registration. The provider's IDs are
    /// used only after it returns.
    @objc optional func onRegister()

    /// Called when the provider is unregistered. Requests in progress may still call `getExtendedIds()`
    /// afterwards, so keep it safe to call.
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
