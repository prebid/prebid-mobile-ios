//
//  BannerEventHandlerStandalone.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

public class BannerEventHandlerStandalone: NSObject, BannerEventHandler {
    
    public weak var loadingDelegate: BannerEventLoadingDelegate?
    public weak var interactionDelegate: BannerEventInteractionDelegate?
    
    public var adSizes: [CGSize] = []
    
    public var isCreativeRequiredForNativeAds: Bool {
        true
    }
    
    public func requestAd(with bidResponse: BidResponse?) {
        loadingDelegate?.prebidDidWin()
    }
    
    public func trackImpression() {
    }
}
