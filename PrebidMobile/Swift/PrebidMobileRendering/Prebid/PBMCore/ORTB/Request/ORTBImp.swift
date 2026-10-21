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

class ORTBImp: NSObject, PBMJsonCodable {

    // MARK: - Properties

    var impID: String?
    var banner: ORTBBanner?
    var video: ORTBVideo?
    var native: ORTBNative?
    var pmp: ORTBPmp = ORTBPmp()
    var displaymanager: String?
    var displaymanagerver: String?
    // Optional despite the nonnull ObjC declaration: `initWithJsonDictionary:` assigned the
    // ivars directly and unconditionally, so an absent JSON key cleared the default back to
    // nil and the key was then omitted on re-encode. See playbook Gap S2.5-C.
    var instl: NSNumber? = 0
    var tagid: String?
    var clickbrowser: NSNumber? = 1
    var secure: NSNumber? = 0
    var rewarded: NSNumber?
    var extPrebid: ORTBImpExtPrebid = ORTBImpExtPrebid()
    var extSkadn: ORTBImpExtSkadn = ORTBImpExtSkadn()
    var extData: NSMutableDictionary? = NSMutableDictionary()
    var extKeywords: String?
    var extGPID: String?

    // MARK: - Init

    override init() {
        super.init()
    }

    required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        impID            = json[.id]
        banner           = json[.banner]
        video            = json[.video]
        native           = json[.native]
        pmp              = json[.pmp] ?? ORTBPmp()
        displaymanager   = json[.displaymanager]
        displaymanagerver = json[.displaymanagerver]
        instl            = json[.instl]
        tagid            = json[.tagid]
        clickbrowser     = json[.clickbrowser]
        secure           = json[.secure]
        rewarded         = json[.rwdd]

        let ext = jsonDictionary["ext"] as? [String: Any]
        extPrebid = ORTBImpExtPrebid(jsonDictionary: ext?["prebid"] as? [String: Any] ?? [:])
        extSkadn  = ORTBImpExtSkadn(jsonDictionary: ext?["skadn"] as? [String: Any] ?? [:])
        if let data = ext?["data"] as? [String: Any] {
            extData = NSMutableDictionary(dictionary: data)
        }
        extKeywords = ext?["keywords"] as? String
        extGPID     = ext?["gpid"] as? String
    }

    // MARK: - PBMJsonEncodable

    var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.id]                = impID
        json[.banner]            = banner
        json[.video]             = video
        json[.native]            = native
        json[.pmp]               = pmp
        json[.displaymanager]    = displaymanager
        json[.displaymanagerver] = displaymanagerver
        json[.instl]             = instl
        json[.tagid]             = tagid
        json[.clickbrowser]      = clickbrowser
        json[.secure]            = secure
        json[.rwdd]              = rewarded

        var result = json.dict
        let ext = extDictionary
        if !ext.isEmpty {
            result["ext"] = ext
        }
        return result
    }

    // MARK: - Private

    private var extDictionary: [String: Any] {
        var dict = [String: Any]()

        // FIXME: (PB-X) Check the necessity of branching the logic with server devs
        let prebidDict = extPrebid.jsonDictionary
        if !prebidDict.isEmpty {
            dict["prebid"] = prebidDict
        } else {
            dict["dlp"] = 1
        }

        let skadnDict = extSkadn.jsonDictionary
        if !skadnDict.isEmpty {
            dict["skadn"] = skadnDict
        }

        if let extData = extData, extData.count > 0 {
            dict["data"] = extData
        }
        if let extKeywords = extKeywords, !extKeywords.isEmpty {
            dict["keywords"] = extKeywords
        }
        if let extGPID = extGPID {
            dict["gpid"] = extGPID
        }
        return dict
    }

    // MARK: - Keys

    private enum Key: String {
        case id, banner, video, native, pmp
        case displaymanager, displaymanagerver, instl, tagid
        case clickbrowser, secure, rwdd
    }
}
