//
//  PrebidOriginalAPIMAXVideoInterstitial.swift
//  InternalTestApp
//
//  Created by Olena Stepaniuk on 03.05.2023.
//  Copyright © 2023 Prebid. All rights reserved.
//

import UIKit
import AppLovinSDK
import PrebidMobile

class PrebidOriginalAPIMAXVideoInterstitial: NSObject, AdaptedController, PrebidConfigurableBannerController, MAAdDelegate {
    
    var refreshInterval: TimeInterval = 0
    var prebidConfigId: String = ""
    var storedAuctionResponse: String?
    
    var interstitialAd: MAInterstitialAd!
    var retryAttempt = 0.0
    
    var adUnitId = ""
    
    // Prebid
    private var adUnit: InterstitialAdUnit!
    
    private weak var adapterViewController: AdapterViewController?
    
    required init(rootController: AdapterViewController) {
        self.adapterViewController = rootController
        super.init()
    }
    
    func loadAd() {
        adUnit = InterstitialAdUnit(configId: prebidConfigId)
        adUnit.adFormats = [.video]
        
        interstitialAd = MAInterstitialAd(adUnitIdentifier: adUnitId)
        interstitialAd.delegate = self
        
        adUnit.fetchDemand(adObject: ALSdk.shared()!.targetingData) { [weak self] resultCode in
            Log.info("Prebid demand fetch for GAM \(resultCode.name())")
            self?.interstitialAd.load()
        }
    }
    
    func didLoad(_ ad: MAAd) {
        retryAttempt = 0
        
        if let interstitialAd = interstitialAd, interstitialAd.isReady {
            interstitialAd.show()
        }
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.interstitialAd.load()
        }
    }
    
    func didDisplay(_ ad: MAAd) {
        
    }
    
    func didHide(_ ad: MAAd) {
        interstitialAd.load()
    }
    
    func didClick(_ ad: MAAd) {
        
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        interstitialAd.load()
    }
}
