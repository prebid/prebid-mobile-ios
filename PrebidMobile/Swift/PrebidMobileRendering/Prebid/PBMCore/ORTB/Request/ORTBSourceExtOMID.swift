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


class ORTBSourceExtOMID: NSObject, PBMJsonCodable {

    // MARK: - Properties

    var omidpn: String?
    var omidpv: String?

    // MARK: - Init

    override init() {
        super.init()
    }

    
    required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        omidpn = json[.omidpn]
        omidpv = json[.omidpv]
    }

    // MARK: - PBMJsonEncodable

    
    var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.omidpn] = omidpn
        json[.omidpv] = omidpv
        return json.dict
    }

    // MARK: - Keys

    private enum Key: String {
        case omidpn, omidpv
    }
}
