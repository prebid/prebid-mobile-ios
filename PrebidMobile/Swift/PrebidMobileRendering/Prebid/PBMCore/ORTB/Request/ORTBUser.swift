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


class ORTBUser: NSObject, PBMJsonCodable {

    // MARK: - Properties

    var keywords: String?
    var customdata: String?
    var geo: ORTBGeo = ORTBGeo()
    var data: [ORTBContentData]?
    var ext: NSMutableDictionary? = NSMutableDictionary()
    var userid: String?
    var eids: [[String: Any]]?

    // MARK: - Init

    override init() {
        super.init()
    }

    
    required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        keywords   = json[.keywords]
        customdata = json[.customdata]
        userid     = json[.id]
        eids       = jsonDictionary["eids"] as? [[String: Any]]
        if let extDict = jsonDictionary["ext"] as? [String: Any] {
            ext = NSMutableDictionary(dictionary: extDict)
        }
        geo        = json[.geo] ?? ORTBGeo()

        if let dataDicts = jsonDictionary["data"] as? [[String: Any]], !dataDicts.isEmpty {
            data = dataDicts.compactMap { ORTBContentData(jsonDictionary: $0) }
        }
    }

    // MARK: - PBMJsonEncodable

    
    var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.keywords]   = keywords
        json[.customdata] = customdata
        json[.id]         = userid

        if geo.lat != nil && geo.lon != nil {
            json[.geo] = geo
        }

        if let data = data, !data.isEmpty {
            json[.data] = data
        }

        var result = json.dict
        if let eids, !eids.isEmpty {
            result["eids"] = eids
        }
        if let ext = ext, ext.count > 0 {
            result["ext"] = ext
        }
        return result
    }

    // MARK: - ObjC API

    func appendEids(_ eids: [[String: Any]]) {
        if ext == nil { ext = NSMutableDictionary() }
        if ext!["eids"] == nil {
            ext!["eids"] = eids
        } else {
            let current = ext!["eids"] as? [[String: Any]] ?? []
            ext!["eids"] = current + eids
        }
    }

    // MARK: - Keys

    private enum Key: String {
        case keywords, customdata, id, geo, data
    }
}
