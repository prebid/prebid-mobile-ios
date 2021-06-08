//
//  BannerAdLoaderDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol BannerAdLoaderDelegate where Self: NSObject {
    
    var eventHandler: BannerEventHandler? { get }

    // Loading callbacks
    @objc func bannerAdLoader(_ bannerAdLoader: PBMBannerAdLoader,
                              loadedAdView adView: UIView,
                              adSize: CGSize)

    // Hook to insert interaction delegate
    @objc func bannerAdLoader(_ bannerAdLoader: PBMBannerAdLoader,
                              createdDisplayView displayView: PBMDisplayView)

}
