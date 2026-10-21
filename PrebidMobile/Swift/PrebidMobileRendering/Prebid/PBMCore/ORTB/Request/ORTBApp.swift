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

class ORTBApp: NSObject, PBMJsonCodable {

    // MARK: - Properties

    var id: String?
    var name: String?
    var bundle: String?
    var domain: String?
    var storeurl: String?
    var cat: [String] = []
    var sectioncat: [String] = []
    var pagecat: [String] = []
    var ver: String?
    var privacypolicy: NSNumber?
    var paid: NSNumber?
    var publisher: ORTBPublisher? = ORTBPublisher()
    var content: ORTBAppContent = ORTBAppContent()
    var keywords: String?
    var ext: ORTBAppExt = ORTBAppExt()

    // MARK: - Init

    override init() {
        super.init()
    }

    required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        id            = json[.id]
        name          = json[.name]
        bundle        = json[.bundle]
        domain        = json[.domain]
        storeurl      = json[.storeurl]
        cat           = (json[.cat] as [String]?) ?? []
        sectioncat    = (json[.sectioncat] as [String]?) ?? []
        pagecat       = (json[.pagecat] as [String]?) ?? []
        ver           = json[.ver]
        privacypolicy = json[.privacypolicy]
        paid          = json[.paid]
        publisher     = json[.publisher] ?? ORTBPublisher()
        keywords      = json[.keywords]
        ext           = json[.ext] ?? ORTBAppExt()
        content       = json[.content] ?? ORTBAppContent()
    }

    // MARK: - PBMJsonEncodable

    var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.id]            = id
        json[.name]          = name
        json[.bundle]        = bundle
        json[.domain]        = domain
        json[.storeurl]      = storeurl
        json[.ver]           = ver
        json[.privacypolicy] = privacypolicy
        json[.paid]          = paid
        json[.keywords]      = keywords
        json[.publisher]     = publisher
        json[.content]       = content
        json[.ext]           = ext
        return json.dict
    }

    // MARK: - Keys

    private enum Key: String {
        case id, name, bundle, domain, storeurl, cat, sectioncat, pagecat
        case ver, privacypolicy, paid, publisher, content, keywords, ext
    }
}
