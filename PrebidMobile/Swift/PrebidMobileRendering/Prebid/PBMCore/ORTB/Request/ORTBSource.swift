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

@objc(PBMORTBSource)
public class ORTBSource: NSObject, PBMJsonCodable {

    // MARK: - Properties

    @objc public var fd: NSNumber?
    @objc public var tid: String?
    @objc public var pchain: String?
    @objc public var extOMID: ORTBSourceExtOMID = ORTBSourceExtOMID()

    // MARK: - Init

    public override init() {
        super.init()
    }

    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        fd      = json[.fd]
        tid     = json[.tid]
        pchain  = json[.pchain]
        extOMID = json[.ext] ?? ORTBSourceExtOMID()
    }

    // MARK: - PBMJsonEncodable

    @objc(toJsonDictionary)
    public var jsonDictionary: [String: Any] {
        var json = JSONObject<Key>()
        json[.fd]     = fd
        json[.tid]    = tid
        json[.pchain] = pchain
        var result = json.dict
        let extDict = extOMID.jsonDictionary
        if !extDict.isEmpty {
            result["ext"] = extDict
        }
        return result
    }

    // MARK: - Keys

    private enum Key: String {
        case fd, tid, pchain, ext
    }
}
