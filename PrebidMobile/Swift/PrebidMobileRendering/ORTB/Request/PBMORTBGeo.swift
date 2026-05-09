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

@objc public class PBMORTBGeo: NSObject, PBMJsonCodable {

    // MARK: - Properties

    @objc public var lat: NSNumber?
    @objc public var lon: NSNumber?
    @objc public var type: NSNumber?
    @objc public var accuracy: NSNumber?
    @objc public var lastfix: NSNumber?
    @objc public var country: String?
    @objc public var region: String?
    @objc public var regionfips104: String?
    @objc public var metro: String?
    @objc public var city: String?
    @objc public var zip: String?
    @objc public var utcoffset: NSNumber?

    // MARK: - Init

    public override init() {
        super.init()
    }

    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String: Any]) {
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

    @objc(toJsonDictionary)
    public var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        // lat/lon converted to NSDecimalNumber to preserve decimal precision on JSON serialization
        json[.lat]          = lat.map { NSDecimalNumber(decimal: $0.decimalValue) }
        json[.lon]          = lon.map { NSDecimalNumber(decimal: $0.decimalValue) }
        json[.type]         = type
        json[.accuracy]     = accuracy
        json[.lastfix]      = lastfix
        json[.country]      = country
        json[.region]       = region
        json[.regionfips104] = regionfips104
        json[.metro]        = metro
        json[.city]         = city
        json[.zip]          = zip
        json[.utcoffset]    = utcoffset
        return json.dict
    }

    // MARK: - Keys

    private enum Key: String {
        case lat, lon, type, accuracy, lastfix
        case country, region, regionfips104, metro, city, zip, utcoffset
    }
}
