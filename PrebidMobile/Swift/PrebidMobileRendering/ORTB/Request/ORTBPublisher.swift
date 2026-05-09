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

@objc(PBMORTBPublisher)
public class ORTBPublisher: NSObject, PBMJsonCodable {

    // MARK: - Properties

    @objc public var publisherID: String?
    @objc public var name: String?
    @objc public var cat: [String] = []
    @objc public var domain: String?

    // MARK: - Init

    public override init() {
        super.init()
    }

    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        publisherID = json[.id]
        name        = json[.name]
        cat         = (json[.cat] as [String]?) ?? []
        domain      = json[.domain]
    }

    // MARK: - PBMJsonEncodable

    @objc(toJsonDictionary)
    public var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.id]     = publisherID
        json[.name]   = name
        json[.domain] = domain
        return json.dict
    }

    // MARK: - Keys

    private enum Key: String {
        case id, name, cat, domain
    }
}
