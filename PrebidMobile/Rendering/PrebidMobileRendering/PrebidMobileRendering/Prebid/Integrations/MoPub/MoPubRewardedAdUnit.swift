//
//  MoPubRewardedAdUnit.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public class MoPubRewardedAdUnit : MoPubBaseInterstitialAdUnit {
    
    // - MARK: Public Methods
    
    public override init(configId: String) {
        super.init(configId: configId)
        
        adUnitConfig.isOptIn = true
        adUnitConfig.adFormat = .video
    }
}
