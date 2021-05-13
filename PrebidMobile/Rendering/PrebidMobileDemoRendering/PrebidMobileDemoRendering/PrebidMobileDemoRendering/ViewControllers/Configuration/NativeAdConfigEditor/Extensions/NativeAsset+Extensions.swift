//
//  NativeAsset+Extensions.swift
//  PrebidMobileDemoRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

extension NativeAsset {
    var name: String
        { String(String(describing: type(of: self)).dropFirst("NativeAsset".count)).lowercased() }
}
