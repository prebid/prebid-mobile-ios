//
//  PrebidOriginalAPIMAXBanner.swift
//  InternalTestApp
//
//  Created by Olena Stepaniuk on 02.05.2023.
//  Copyright © 2023 Prebid. All rights reserved.
//

import AppLovinSDK
import PrebidMobile

class PrebidOriginalAPIMAXBanner: NSObject, AdaptedController, PrebidConfigurableBannerController, MAAdViewAdDelegate {
    
    var refreshInterval: TimeInterval = 0
    var prebidConfigId: String = ""
    
    var adSize = CGSize.zero
    var adUnitId = ""

    private weak var rootController: AdapterViewController?
    
    // MAX
    private var adView: MAAdView!
    
    // Prebid
    private var adUnit: BannerAdUnit!
    
    required init(rootController: AdapterViewController) {
        self.rootController = rootController
        super.init()
    }
    
    func loadAd() {
        createBannerAd()
    }
    
    func createBannerAd() {
        adUnit = BannerAdUnit(configId: prebidConfigId, size: adSize)
        adUnit.setAutoRefreshMillis(time: refreshInterval)
        
        adView = MAAdView(adUnitIdentifier: adUnitId)
        adView.delegate = self
        
        adView.frame = CGRect(x: 0, y: 0, width: adSize.width, height: adSize.height)
        adView.backgroundColor = .clear
        rootController?.bannerView.addSubview(adView)
        
        adUnit.fetchDemand(adObject: ALSdk.shared()!.targetingData) { [weak self] resultCode in
            Log.info("Prebid demand fetch for GAM \(resultCode.name())")
            self?.adView.loadAd()
        }
    }
    
    // MARK: MAAdDelegate Protocol
    
    func didLoad(_ ad: MAAd) {
        
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        print(error)
    }
    
    func didClick(_ ad: MAAd) {}
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {}
    
    func didDisplay(_ ad: MAAd) {}
    
    func didHide(_ ad: MAAd) {}
    
    
    // MARK: MAAdViewAdDelegate Protocol
    
    func didExpand(_ ad: MAAd) {}
    func didCollapse(_ ad: MAAd) {}
}
