/*   Copyright 2018-2021 Prebid.org, Inc.

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

@objc public class PBMORTBImpExtSkadn: NSObject, PBMJsonCodable {

    // MARK: - Properties

    @objc public var sourceapp: String?
    @objc public var skadnetids: [String] = []
    @objc public var skoverlay: NSNumber?

    // MARK: - Init

    public override init() {
        super.init()
    }

    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        sourceapp  = json[.sourceapp]
        skadnetids = (json[.skadnetids] as [String]?) ?? []
        skoverlay  = json[.skoverlay]
    }

    // MARK: - PBMJsonEncodable

    @objc(toJsonDictionary)
    public var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        if let sourceapp = sourceapp, !skadnetids.isEmpty {
            json[.versions]   = Self.supportedSKAdNetworkVersions
            json[.sourceapp]  = sourceapp
            json[.skadnetids] = skadnetids
            json[.skoverlay]  = skoverlay
        }
        return json.dict
    }

    private static var supportedSKAdNetworkVersions: [String] {
        var versions = [String]()
        if #available(iOS 14.5, *) { versions.append("2.2") }
        if #available(iOS 14.6, *) { versions.append("3.0") }
        if #available(iOS 16.2, *) { versions.append("4.0") }
        return versions
    }

    // MARK: - Keys

    private enum Key: String {
        case versions, sourceapp, skadnetids, skoverlay
    }
}
