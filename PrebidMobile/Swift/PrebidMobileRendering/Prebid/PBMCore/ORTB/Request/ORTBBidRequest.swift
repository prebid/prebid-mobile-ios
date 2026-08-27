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

@objc(PBMORTBBidRequest)
public class ORTBBidRequest: NSObject, PBMJsonCodable, NSCopying {

    // MARK: - Properties

    @objc public var requestID: String?
    @objc public var imp: [ORTBImp] = [ORTBImp()]
    @objc public var app: ORTBApp = ORTBApp()
    @objc public var device: ORTBDevice = ORTBDevice()
    @objc public var user: ORTBUser = ORTBUser()
    @objc public var test: NSNumber?
    @objc public var tmax: NSNumber?
    @objc public var regs: ORTBRegs = ORTBRegs()
    @objc public var source: ORTBSource = ORTBSource()
    @objc public var extPrebid: ORTBBidRequestExtPrebid = ORTBBidRequestExtPrebid()

    // MARK: - Init

    public override init() {
        super.init()
    }

    @objc(initWithJsonDictionary:)
    public required init(jsonDictionary: [String: Any]) {
        super.init()
        let json = JSONObject<Key>(jsonDictionary)
        requestID = json[.id]
        test      = json[.test]
        tmax      = json[.tmax]
        app       = json[.app]    ?? ORTBApp()
        device    = json[.device] ?? ORTBDevice()
        user      = json[.user]   ?? ORTBUser()
        regs      = json[.regs]   ?? ORTBRegs()
        source    = json[.source] ?? ORTBSource()
        extPrebid = ORTBBidRequestExtPrebid(
            jsonDictionary: (jsonDictionary["ext"] as? [String: Any])?["prebid"] as? [String: Any] ?? [:]
        )

        // Assigned unconditionally, matching `initWithJsonDictionary:` — decoding a request
        // with a missing or empty "imp" must clear the one-element default, not preserve it,
        // or re-encoding invents a phantom impression. See playbook Gap S2.5-C.
        //
        // Deliberate divergence from ObjC: the cast to `NSArray<NSDictionary *> *` was
        // unchecked, so one non-dictionary element corrupted every impression in the
        // request. Dropping only the malformed elements keeps the valid ones usable.
        // Pinned by `testDecodingRequestWithMalformedImpElements`.
        let impDicts = jsonDictionary["imp"] as? [Any] ?? []
        imp = impDicts.compactMap { ($0 as? [String: Any]).map { ORTBImp(jsonDictionary: $0) } }
    }

    // MARK: - PBMJsonEncodable

    @objc(toJsonDictionary)
    public var jsonDictionary: [String: Any] {
        var result = [String: Any]()

        // imp and ext are set first so arbitrary params from API/JSON don't override them
        result["imp"] = imp.map { $0.jsonDictionary }

        let prebidDict = extPrebid.jsonDictionary
        if !prebidDict.isEmpty {
            result["ext"] = ["prebid": prebidDict]
        }

        if let requestID = requestID { result["id"] = requestID }

        let appDict = app.jsonDictionary
        if !appDict.isEmpty { result["app"] = appDict }

        let deviceDict = device.jsonDictionary
        if !deviceDict.isEmpty { result["device"] = deviceDict }

        let userDict = user.jsonDictionary
        if !userDict.isEmpty { result["user"] = userDict }

        if let test = test { result["test"] = test }
        if let tmax = tmax { result["tmax"] = tmax }

        let regsDict = regs.jsonDictionary
        if !regsDict.isEmpty { result["regs"] = regsDict }

        let sourceDict = source.jsonDictionary
        if !sourceDict.isEmpty { result["source"] = sourceDict }

        return result
    }

    // MARK: - NSCopying (JSON round-trip, matching original PBMORTBAbstract behaviour)

    public func copy(with zone: NSZone? = nil) -> Any {
        ORTBBidRequest(jsonDictionary: jsonDictionary)
    }

    // MARK: - Keys

    private enum Key: String {
        case id, imp, app, device, user, test, tmax, regs, source
    }
}
