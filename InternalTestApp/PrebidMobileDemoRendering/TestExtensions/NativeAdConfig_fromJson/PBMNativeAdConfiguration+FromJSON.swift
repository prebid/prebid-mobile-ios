/*   Copyright 2018-2021 Prebid.org, Inc.

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

import PrebidMobile

extension NativeAdConfiguration {
    convenience init?(json: [String: Any]) {
        guard let rawAssets = json["assets"] as? [[String: Any]] else {
            return nil
        }
        self.init(assets: rawAssets.compactMap(NativeAsset.parse(json:)))
        version = json["ver"] as? String
        
        context = json["context"] as? Int ?? 0
        contextsubtype = json["contextsubtype"] as? Int ?? 0
        plcmttype = json["plcmttype"] as? Int ?? 0

//        plcmtcnt = json["plcmtcnt"] as? NSNumber
        seq = json["seq"] as? NSNumber
//        aurlsupport = json["aurlsupport"] as? NSNumber
//        durlsupport = json["durlsupport"] as? NSNumber
        if let rawTrackers = json["eventtrackers"] as? [[String: Any]] {
            eventtrackers = rawTrackers.compactMap(NativeEventTracker.init(json:))
        }
        privacy = json["privacy"] as? NSNumber
        try? setExt((json["ext"] as? [String: AnyHashable])!)
    }
    
    private func enumValue<T: RawRepresentable>(_ value: Any?) -> T! where T.RawValue == Int {
        return T(rawValue: value as? Int ?? 0)
    }
}
