//
//  OXANativeAdConfiguration+FromJSON.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

extension OXANativeAdConfiguration {
    convenience init?(json: [String: Any]) {
        guard let rawAssets = json["assets"] as? [[String: Any]] else {
            return nil
        }
        self.init(assets: rawAssets.compactMap(OXANativeAsset.parse(json:)))
        version = json["ver"] as? String
        
        context = enumValue(json["context"])
        contextsubtype = enumValue(json["contextsubtype"])
        plcmttype = enumValue(json["plcmttype"])

//        plcmtcnt = json["plcmtcnt"] as? NSNumber
        seq = json["seq"] as? NSNumber
//        aurlsupport = json["aurlsupport"] as? NSNumber
//        durlsupport = json["durlsupport"] as? NSNumber
        if let rawTrackers = json["eventtrackers"] as? [[String: Any]] {
            eventtrackers = rawTrackers.compactMap(OXANativeEventTracker.init(json:))
        }
        privacy = json["privacy"] as? NSNumber
        try? setExt(json["ext"] as? [String: Any])
    }
    
    private func enumValue<T: RawRepresentable>(_ value: Any?) -> T! where T.RawValue == Int {
        return T(rawValue: value as? Int ?? 0)
    }
}
