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

@objc(PBMORTBDevice)
public class ORTBDevice: NSObject, PBMJsonCodable {

    // MARK: - Properties

    @objc public var ua: String?
    @objc public var geo: ORTBGeo = ORTBGeo()
    @objc public var lmt: NSNumber?
    @objc public var devicetype: NSNumber?
    @objc public var make: String?
    @objc public var model: String?
    @objc public var os: String?
    @objc public var osv: String?
    @objc public var hwv: String?
    @objc public var h: NSNumber?
    @objc public var w: NSNumber?
    @objc public var ppi: NSNumber?
    @objc public var pxratio: NSNumber?
    @objc public var js: NSNumber?
    @objc public var geofetch: NSNumber?
    @objc public var flashver: String?
    @objc public var language: String?
    @objc public var carrier: String?
    @objc public var mccmnc: String?
    @objc public var connectiontype: NSNumber?
    @objc public var ifa: String?
    @objc public var didsha1: String?
    @objc public var didmd5: String?
    @objc public var dpidsha1: String?
    @objc public var dpidmd5: String?
    @objc public var macsha1: String?
    @objc public var macmd5: String?
    @objc public var extPrebid: ORTBDeviceExtPrebid = ORTBDeviceExtPrebid()
    @objc public var extAtts: ORTBDeviceExtAtts = ORTBDeviceExtAtts()

    // MARK: - Init

    public override init() {
        super.init()
    }

    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        ua             = json[.ua]
        geo            = json[.geo] ?? ORTBGeo()
        lmt            = json[.lmt]
        devicetype     = json[.devicetype]
        make           = json[.make]
        model          = json[.model]
        os             = json[.os]
        osv            = json[.osv]
        hwv            = json[.hwv]
        h              = json[.h]
        w              = json[.w]
        ppi            = json[.ppi]
        pxratio        = json[.pxratio]
        js             = json[.js]
        geofetch       = json[.geofetch]
        flashver       = json[.flashver]
        language       = json[.language]
        carrier        = json[.carrier]
        mccmnc         = json[.mccmnc]
        connectiontype = json[.connectiontype]
        ifa            = json[.ifa]
        didsha1        = json[.didsha1]
        didmd5         = json[.didmd5]
        dpidsha1       = json[.dpidsha1]
        dpidmd5        = json[.dpidmd5]
        macsha1        = json[.macsha1]
        macmd5         = json[.macmd5]

        let ext = jsonDictionary["ext"] as? [String: Any]
        extPrebid = ORTBDeviceExtPrebid(jsonDictionary: ext?["prebid"] as? [String: Any] ?? [:])
        extAtts   = ORTBDeviceExtAtts(jsonDictionary: ext ?? [:])
    }

    // MARK: - PBMJsonEncodable

    @objc(toJsonDictionary)
    public var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.ua]             = ua
        json[.geo]            = geo
        json[.lmt]            = lmt
        json[.devicetype]     = devicetype
        json[.make]           = make
        json[.model]          = model
        json[.os]             = os
        json[.osv]            = osv
        json[.h]              = h
        json[.w]              = w
        json[.ppi]            = ppi
        json[.pxratio]        = pxratio
        json[.js]             = js
        json[.geofetch]       = geofetch
        json[.flashver]       = flashver
        json[.language]       = language
        json[.carrier]        = carrier
        json[.mccmnc]         = mccmnc
        json[.connectiontype] = connectiontype
        json[.didsha1]        = didsha1
        json[.didmd5]         = didmd5
        json[.hwv]            = hwv

        if let ifa = ifa {
            json[.ifa] = ifa
        } else {
            json[.dpidsha1] = dpidsha1
            json[.dpidmd5]  = dpidmd5
            json[.macsha1]  = macsha1
            json[.macmd5]   = macmd5
        }

        var result = json.dict
        var ext = [String: Any]()
        let prebidDict = extPrebid.jsonDictionary
        if !prebidDict.isEmpty { ext["prebid"] = prebidDict }
        let attsDict = extAtts.jsonDictionary
        ext.merge(attsDict) { _, new in new }
        if !ext.isEmpty { result["ext"] = ext }
        return result
    }

    // MARK: - Keys

    private enum Key: String {
        case ua, geo, lmt, devicetype, make, model, os, osv, hwv
        case h, w, ppi, pxratio, js, geofetch, flashver, language
        case carrier, mccmnc, connectiontype, ifa
        case didsha1, didmd5, dpidsha1, dpidmd5, macsha1, macmd5
    }
}
