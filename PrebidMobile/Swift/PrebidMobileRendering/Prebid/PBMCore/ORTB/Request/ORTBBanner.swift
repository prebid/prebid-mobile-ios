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

class ORTBBanner: NSObject, PBMJsonCodable {

    // MARK: - Properties

    var format: [ORTBFormat] = []
    var pos: NSNumber?
    var api: [NSNumber]?

    // MARK: - Init

    override init() {
        super.init()
    }

    required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        pos    = json[.pos]
        api    = json[.api]
        format = json[.format] ?? []
    }

    // MARK: - PBMJsonEncodable

    var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.pos] = pos
        if let api = api, !api.isEmpty {
            json[.api] = api
        }
        if !format.isEmpty {
            json[.format] = format
        }
        return json.dict
    }

    // MARK: - Keys

    private enum Key: String {
        case format, pos, api
    }
}
