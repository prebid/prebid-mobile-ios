//
//  PBMNativeEventTracker+FromJSON.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import PrebidMobileRendering

extension NativeEventTracker {
    convenience init?(json: [String: Any]) {
        guard let rawEvent = json["event"] as? NSNumber,
              let methods = json["methods"] as? [Int]
        else {
            return nil
        }
        self.init(event: rawEvent.intValue, methods: methods)
        try? setExt(json["ext"] as? [String: AnyHashable] ?? [:])
    }
}
