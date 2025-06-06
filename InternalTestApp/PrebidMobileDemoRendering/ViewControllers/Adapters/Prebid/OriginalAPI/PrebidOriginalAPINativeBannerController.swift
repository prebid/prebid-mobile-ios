/*   Copyright 2018-2021 Prebid.org, Inc.
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
  http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

import UIKit
import PrebidMobile
import PrebidMobileAdMobAdapters
import GoogleMobileAds

class PrebidOriginalAPINativeBannerController:
        NSObject,
        AdaptedController,
        GoogleMobileAds.BannerViewDelegate {
    
    var prebidConfigId = ""
    var adUnitID = ""
    
    // Prebid
    private var nativeUnit: NativeRequest!
    public var nativeAssets: [NativeAsset]?
    public var eventTrackers: [NativeEventTracker]?
    
    // GAM
    private var gamBannerView: AdManagerBannerView!
    private let gamRequest = AdManagerRequest()
    
    private weak var rootController: AdapterViewController?
    
    private let bannerViewDidReceiveAd = EventReportContainer()
    private let bannerViewDidFailToReceiveAd = EventReportContainer()
    private let bannerViewDidRecordImpression = EventReportContainer()
    private let bannerViewDidRecordClick = EventReportContainer()
    private let bannerViewWillPresentScreen = EventReportContainer()
    private let bannerViewWillDismissScreen = EventReportContainer()
    private let bannerViewDidDismissScreen = EventReportContainer()
    
    private let configIdLabel = UILabel()
    
    required init(rootController: AdapterViewController) {
        super.init()
        self.rootController = rootController
        
        setupAdapterController()
    }
    
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        nativeUnit = NativeRequest(configId: prebidConfigId, assets: nativeAssets)
        
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        nativeUnit.eventtrackers = eventTrackers
                
        gamBannerView = AdManagerBannerView(adSize: AdSizeFluid)
        gamBannerView.adUnitID = adUnitID
        gamBannerView.rootViewController = self.rootController
        gamBannerView.delegate = self
        
        rootController?.bannerView.addSubview(gamBannerView)
        
        nativeUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            Log.info("Prebid demand fetch for GAM \(resultCode.name())")
            
            self?.gamBannerView.load(self?.gamRequest)
        }
    }
    
    private func setupAdapterController() {
        rootController?.showButton.isHidden = true
        configIdLabel.isHidden = true
        setupActions()
        
        rootController?.actionsView.addArrangedSubview(configIdLabel)
    }
    
    private func setupActions() {
        rootController?.setupAction(bannerViewDidReceiveAd, "bannerViewDidReceiveAd called", accessibilityLabel: "bannerViewDidReceiveAd called")
        rootController?.setupAction(bannerViewDidFailToReceiveAd, "bannerViewDidFailToReceiveAd called")
        rootController?.setupAction(bannerViewDidRecordImpression, "bannerViewDidRecordImpression called")
        rootController?.setupAction(bannerViewDidRecordClick, "bannerViewDidRecordClick called")
        rootController?.setupAction(bannerViewWillPresentScreen, "bannerViewWillPresentScreen called")
        rootController?.setupAction(bannerViewWillDismissScreen, "bannerViewWillDismissScreen called")
        rootController?.setupAction(bannerViewDidDismissScreen, "bannerViewDidDismissScreen called")
    }
    
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GoogleMobileAds.BannerView) {
        bannerViewDidReceiveAd.isEnabled = true
        
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { size in
            guard let bannerView = bannerView as? AdManagerBannerView else { return }
            bannerView.resize(adSizeFor(cgSize: size))
        }, failure: { (error) in
            Log.error("Error occuring during searching for Prebid creative size: \(error)")
        })
        
        rootController?.bannerView.constraints.first { $0.firstAttribute == .width }?.constant = bannerView.adSize.size.width
        rootController?.bannerView.constraints.first { $0.firstAttribute == .height }?.constant = bannerView.adSize.size.height
    }
    
    func bannerView(_ bannerView: GoogleMobileAds.BannerView, didFailToReceiveAdWithError error: Error) {
        bannerViewDidFailToReceiveAd.isEnabled = true
        Log.error(error.localizedDescription)
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GoogleMobileAds.BannerView) {
        bannerViewDidRecordImpression.isEnabled = true
    }
    
    func bannerViewDidRecordClick(_ bannerView: GoogleMobileAds.BannerView) {
        bannerViewDidRecordClick.isEnabled = true
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GoogleMobileAds.BannerView) {
        bannerViewWillPresentScreen.isEnabled = true
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GoogleMobileAds.BannerView) {
        bannerViewWillDismissScreen.isEnabled = true
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GoogleMobileAds.BannerView) {
        bannerViewDidDismissScreen.isEnabled = true
    }
}
