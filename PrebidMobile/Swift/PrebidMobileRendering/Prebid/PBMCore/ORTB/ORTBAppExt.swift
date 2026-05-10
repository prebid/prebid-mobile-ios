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

@objc(PBMORTBAppExt)
public class ORTBAppExt: NSObject, PBMJsonCodable {

    // MARK: - Properties

    @objc public var prebid: ORTBAppExtPrebid = ORTBAppExtPrebid()
    @objc public var data: [String: [String]]?

    // MARK: - Init

    public override init() {
        super.init()
    }

    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        prebid = json[.prebid] ?? ORTBAppExtPrebid()
        data   = jsonDictionary["data"] as? [String: [String]]
    }

    // MARK: - PBMJsonEncodable

    @objc(toJsonDictionary)
    public var jsonDictionary: [String: Any] {
        var result = [String: Any]()
        let prebidDict = prebid.jsonDictionary
        if !prebidDict.isEmpty {
            result["prebid"] = prebidDict
        }
        if let data = data {
            result["data"] = data
        }
        return result
    }

    // MARK: - Keys

    private enum Key: String {
        case prebid, data
    }
}
