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

@objc public class PBMORTBDeal: NSObject, PBMJsonCodable {

    // MARK: - Properties

    @objc public var id: String?
    @objc public var bidfloor: NSNumber = 0.0
    @objc public var bidfloorcur: String = "USD"
    @objc public var at: NSNumber?
    @objc public var wseat: [String] = []
    @objc public var wadomain: [String] = []

    // MARK: - Init

    public override init() {
        super.init()
    }

    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        id          = json[.id]
        bidfloor    = json[.bidfloor] ?? 0.0
        bidfloorcur = json[.bidfloorcur] ?? "USD"
        at          = json[.at]
        wseat       = (json[.wseat] as [String]?) ?? []
        wadomain    = (json[.wadomain] as [String]?) ?? []
    }

    // MARK: - PBMJsonEncodable

    @objc(toJsonDictionary)
    public var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.id]          = id
        json[.bidfloor]    = bidfloor
        json[.bidfloorcur] = bidfloorcur
        json[.at]          = at
        json[.wseat]       = wseat
        json[.wadomain]    = wadomain
        return json.dict
    }

    // MARK: - Keys

    private enum Key: String {
        case id, bidfloor, bidfloorcur, at, wseat, wadomain
    }
}
