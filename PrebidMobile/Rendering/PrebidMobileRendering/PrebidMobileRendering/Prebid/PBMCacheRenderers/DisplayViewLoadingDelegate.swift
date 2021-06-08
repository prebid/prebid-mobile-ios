//
//  DisplayViewLoadingDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public protocol DisplayViewLoadingDelegate where Self : NSObject {

    func displayViewDidLoadAd(_ displayView: PBMDisplayView)
    
    func displayView(_ displayView: PBMDisplayView,
                     didFailWithError error: Error)
}
