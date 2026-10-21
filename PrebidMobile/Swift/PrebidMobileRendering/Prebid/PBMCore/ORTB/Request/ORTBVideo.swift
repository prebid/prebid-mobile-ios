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

class ORTBVideo: NSObject, PBMJsonCodable {

    // MARK: - Properties

    var mimes: [String]?
    var minduration: NSNumber?
    var maxduration: NSNumber?
    var protocols: [NSNumber]?
    var w: NSNumber?
    var h: NSNumber?
    var startdelay: NSNumber?
    var placement: NSNumber?
    var plcmt: NSNumber?
    var linearity: NSNumber?
    var minbitrate: NSNumber?
    var maxbitrate: NSNumber?
    var playbackend: NSNumber?
    var delivery: [NSNumber]?
    var pos: NSNumber?
    var api: [NSNumber]?
    var battr: [NSNumber]?
    var skip: NSNumber?
    var playbackmethod: [NSNumber]?

    // MARK: - Init

    override init() {
        super.init()
    }

    required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        mimes          = json[.mimes]
        minduration    = json[.minduration]
        maxduration    = json[.maxduration]
        protocols      = json[.protocols]
        w              = json[.w]
        h              = json[.h]
        startdelay     = json[.startdelay]
        placement      = json[.placement]
        plcmt          = json[.plcmt]
        linearity      = json[.linearity]
        minbitrate     = json[.minbitrate]
        maxbitrate     = json[.maxbitrate]
        playbackend    = json[.playbackend]
        delivery       = json[.delivery]
        pos            = json[.pos]
        api            = json[.api]
        battr          = json[.battr]
        skip           = json[.skip]
        playbackmethod = json[.playbackmethod]
    }

    // MARK: - PBMJsonEncodable

    var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.mimes]       = mimes
        json[.minduration] = minduration
        json[.maxduration] = maxduration
        json[.protocols]   = protocols
        json[.w]           = w
        json[.h]           = h
        json[.startdelay]  = startdelay
        json[.placement]   = placement
        json[.plcmt]       = plcmt
        json[.linearity]   = linearity
        json[.minbitrate]  = minbitrate
        json[.maxbitrate]  = maxbitrate
        json[.playbackend] = playbackend
        json[.delivery]    = delivery
        json[.pos]         = pos
        json[.skip]        = skip
        if let api = api, !api.isEmpty {
            json[.api] = api
        }
        if let battr = battr, !battr.isEmpty {
            json[.battr] = battr
        }
        if let playbackmethod = playbackmethod, !playbackmethod.isEmpty {
            json[.playbackmethod] = playbackmethod
        }
        return json.dict
    }

    // MARK: - Keys

    private enum Key: String {
        case mimes, minduration, maxduration, protocols, w, h
        case startdelay, placement, plcmt, linearity
        case minbitrate, maxbitrate, playbackend, delivery, pos
        case api, battr, skip, playbackmethod
    }
}
