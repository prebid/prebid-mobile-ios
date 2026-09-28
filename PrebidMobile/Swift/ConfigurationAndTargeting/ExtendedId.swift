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

/// An OpenRTB Extended Identifier (EID): one entry of `user.eids` (OpenRTB 2.6) or `user.ext.eids` (OpenRTB 2.5).
///
/// Use `ExternalUserId` to build an EID from individual fields, or `RawExtendedId` to wrap a pre-built
/// JSON dictionary. See the [OpenRTB EID specification](https://github.com/InteractiveAdvertisingBureau/openrtb/blob/main/extensions/2.x_official_extensions/eids.md).
@objc
public protocol ExtendedId: AnyObject {

    /// The source domain of this EID (e.g. `"criteo.com"`).
    @objc var source: String { get }

    /// The OpenRTB JSON representation of this EID.
    ///
    /// An empty dictionary, or one that `JSONSerialization` can't encode, is not sent.
    @objc func toJSONDictionary() -> [String: Any]
}

/// An `ExtendedId` backed by a pre-built OpenRTB EID JSON dictionary, for identity libraries that
/// already produce the EID object, e.g. `["source": "id5-sync.com", "uids": [["id": "...", "atype": 1]]]`.
@objcMembers
public class RawExtendedId: NSObject, ExtendedId {

    /// The `source` field of the wrapped JSON.
    public let source: String

    private let json: [String: Any]

    /// Wraps an OpenRTB EID JSON dictionary.
    ///
    /// Returns `nil` if `json` has no non-empty `source` string, or if `JSONSerialization` can't encode it.
    public init?(json: [String: Any]) {
        guard let source = json["source"] as? String, !source.isEmpty else {
            Log.warn("Extended ID JSON must contain a non-empty \"source\" string: \(json)")
            return nil
        }

        guard JSONSerialization.isValidJSONObject(json) else {
            Log.warn("Extended ID JSON can't be encoded: \(json)")
            return nil
        }

        self.source = source
        self.json = json

        super.init()
    }

    /// Returns the wrapped JSON.
    public func toJSONDictionary() -> [String: Any] {
        json
    }
}
