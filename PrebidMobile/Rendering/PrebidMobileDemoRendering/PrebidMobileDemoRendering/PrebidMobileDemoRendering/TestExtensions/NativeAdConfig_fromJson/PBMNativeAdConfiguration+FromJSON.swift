//
//  NativeAdConfiguration+FromJSON.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

import PrebidMobileRendering

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
