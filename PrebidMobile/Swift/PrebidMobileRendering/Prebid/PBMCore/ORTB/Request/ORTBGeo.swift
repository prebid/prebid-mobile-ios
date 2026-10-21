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

class ORTBGeo: NSObject, PBMJsonCodable {

    // MARK: - Properties

    var lat: NSNumber?
    var lon: NSNumber?
    var type: NSNumber?
    var accuracy: NSNumber?
    var lastfix: NSNumber?
    var country: String?
    var region: String?
    var regionfips104: String?
    var metro: String?
    var city: String?
    var zip: String?
    var utcoffset: NSNumber?

    // MARK: - Init

    override init() {
        super.init()
    }

    required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        lat           = json[.lat]
        lon           = json[.lon]
        type          = json[.type]
        accuracy      = json[.accuracy]
        lastfix       = json[.lastfix]
        country       = json[.country]
        region        = json[.region]
        regionfips104 = json[.regionfips104]
        metro         = json[.metro]
        city          = json[.city]
        zip           = json[.zip]
        utcoffset     = json[.utcoffset]
    }

    // MARK: - PBMJsonEncodable

    var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        // lat/lon converted to NSDecimalNumber to preserve decimal precision on JSON serialization
        json[.lat]           = lat.map { NSDecimalNumber(decimal: $0.decimalValue) }
        json[.lon]           = lon.map { NSDecimalNumber(decimal: $0.decimalValue) }
        json[.type]          = type
        json[.accuracy]      = accuracy
        json[.lastfix]       = lastfix
        json[.country]       = country
        json[.region]        = region
        json[.regionfips104] = regionfips104
        json[.metro]         = metro
        json[.city]          = city
        json[.zip]           = zip
        json[.utcoffset]     = utcoffset
        return json.dict
    }

    // MARK: - Keys

    private enum Key: String {
        case lat, lon, type, accuracy, lastfix
        case country, region, regionfips104, metro, city, zip, utcoffset
    }
}
