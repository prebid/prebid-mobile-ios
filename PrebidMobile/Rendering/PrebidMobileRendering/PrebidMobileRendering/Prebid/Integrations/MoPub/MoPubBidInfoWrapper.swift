//
//  MoPubBidInfoWrapper.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class MoPubBidInfoWrapper : NSObject {
    @objc public var keywords: String?
    @objc public var localExtras: [AnyHashable : Any]?
}
