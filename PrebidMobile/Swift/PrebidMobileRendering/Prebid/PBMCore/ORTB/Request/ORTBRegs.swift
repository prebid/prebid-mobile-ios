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

@objc(PBMORTBRegs)
public class ORTBRegs: NSObject, PBMJsonCodable {

    // MARK: - Properties

    // coppa only accepts 0 or 1; any other value is treated as nil
    private var _coppa: NSNumber?
    @objc public var coppa: NSNumber? {
        get { _coppa }
        set {
            guard let val = newValue, val == 0 || val == 1 else { _coppa = nil; return }
            _coppa = val
        }
    }

    @objc public var gpp: String?
    @objc public var gppSID: [NSNumber]?
    @objc public var ext: NSMutableDictionary? = NSMutableDictionary()

    // MARK: - Init

    public override init() {
        super.init()
    }

    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        _coppa = json[.coppa]
        gpp    = json[.gpp]
        gppSID = json[.gppSID]
    }

    // MARK: - PBMJsonEncodable

    @objc(toJsonDictionary)
    public var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.coppa]  = _coppa
        json[.gpp]    = gpp
        json[.gppSID] = gppSID
        var result = json.dict
        if let ext = ext, ext.count > 0 {
            result["ext"] = ext
        }
        return result
    }

    // MARK: - Keys

    private enum Key: String {
        case coppa, gpp
        case gppSID = "gpp_sid"
    }
}
