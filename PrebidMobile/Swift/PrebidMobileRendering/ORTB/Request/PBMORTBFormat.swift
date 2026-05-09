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

@objc public class PBMORTBFormat: NSObject, PBMJsonCodable {

    // MARK: - Properties

    @objc public var w: NSNumber?
    @objc public var h: NSNumber?
    @objc public var wratio: NSNumber?
    @objc public var hratio: NSNumber?
    @objc public var wmin: NSNumber?

    // MARK: - Init

    public override init() {
        super.init()
    }

    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        w      = json[.w]
        h      = json[.h]
        wratio = json[.wratio]
        hratio = json[.hratio]
        wmin   = json[.wmin]
    }

    // MARK: - PBMJsonEncodable

    @objc(toJsonDictionary)
    public var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.w]      = w
        json[.h]      = h
        json[.wratio] = wratio
        json[.hratio] = hratio
        json[.wmin]   = wmin
        return json.dict
    }

    // MARK: - NSObject equality (Gap 3 — used in NSSet deduplication)

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PBMORTBFormat else { return false }
        return w == other.w && h == other.h
    }

    public override var hash: Int { (w?.hashValue ?? 0) ^ (h?.hashValue ?? 0) }

    // MARK: - Keys

    private enum Key: String {
        case w, h, wratio, hratio, wmin
    }
}
