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
import GoogleMobileAds

class PrebidOriginalAPIDisplayBannerController:
    NSObject,
    AdaptedController,
    PrebidConfigurableBannerController,
    GADBannerViewDelegate {
    
    weak var rootController: AdapterViewController?
    var prebidConfigId = ""
    var adUnitID = ""
    
    var refreshInterval: TimeInterval = 0
    var adSize = CGSize.zero
    var gamSizes = [GADAdSize]()
    
    // Prebid
    private var adUnit: BannerAdUnit!
    
    // GAM
    private var gamBanner: GAMBannerView!
    
    private let bannerViewDidReceiveAd = EventReportContainer()
    private let bannerViewDidFailToReceiveAd = EventReportContainer()
    private let bannerViewDidRecordImpression = EventReportContainer()
    private let bannerViewDidRecordClick = EventReportContainer()
    private let bannerViewWillPresentScreen = EventReportContainer()
    private let bannerViewWillDismissScreen = EventReportContainer()
    private let bannerViewDidDismissScreen = EventReportContainer()
    
    private let reloadButton = ThreadCheckingButton()
    private let stopRefreshButton = ThreadCheckingButton()
    
    private let configIdLabel = UILabel()
    
    required init(rootController: AdapterViewController) {
        super.init()
        
        self.rootController = rootController
        
        reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        stopRefreshButton.addTarget(self, action: #selector(stopRefresh), for: .touchUpInside)
        
        setupAdapterController()
    }
    
    func configurationController() -> BaseConfigurationController? {
        return PrebidBannerConfigurationController(controller: self)
    }
    
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        adUnit = BannerAdUnit(configId: prebidConfigId, size: adSize)
        adUnit.setAutoRefreshMillis(time: refreshInterval)
        
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(key: dataPair.key, value: dataPair.value)
            }
        }
        
        // imp[].ext.keywords
        if !AppConfiguration.shared.adUnitContextKeywords.isEmpty {
            for keyword in AppConfiguration.shared.adUnitContextKeywords {
                adUnit?.addContextKeyword(keyword)
            }
        }
        
        // user.data
        if let userData = AppConfiguration.shared.userData {
            let ortbUserData = PBMORTBContentData()
            ortbUserData.ext = [:]
            
            for dataPair in userData {
                ortbUserData.ext?[dataPair.key] = dataPair.value
            }
            
            adUnit?.addUserData([ortbUserData])
        }
        
        // app.content.data
        if let appData = AppConfiguration.shared.appContentData {
            let ortbAppContentData = PBMORTBContentData()
            ortbAppContentData.ext = [:]
            
            for dataPair in appData {
                ortbAppContentData.ext?[dataPair.key] = dataPair.value
            }
            
            adUnit?.addAppContentData([ortbAppContentData])
        }
        
        gamBanner = GAMBannerView(adSize: gamSizes.first ?? GADAdSizeFromCGSize(adSize))
        gamBanner.validAdSizes = gamSizes.map(NSValueFromGADAdSize)
        gamBanner.adUnitID = adUnitID
        gamBanner.rootViewController = rootController
        gamBanner.delegate = self
        
        rootController?.bannerView?.addSubview(gamBanner)
        
        let gamRequest = GAMRequest()
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            Log.info("Prebid demand fetch for GAM \(resultCode.name())")
            self?.gamBanner.load(gamRequest)
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
        
        rootController?.setupAction(reloadButton, "[Reload]")
        rootController?.setupAction(stopRefreshButton, "[Stop Refresh]")
        stopRefreshButton.isEnabled = true
    }
    
    private func resetEvents() {
        bannerViewDidReceiveAd.isEnabled = false
        bannerViewDidFailToReceiveAd.isEnabled = false
        bannerViewDidRecordImpression.isEnabled = false
        bannerViewDidRecordClick.isEnabled = false
        bannerViewWillPresentScreen.isEnabled = false
        bannerViewWillDismissScreen.isEnabled = false
        bannerViewDidDismissScreen.isEnabled = false
    }
    
    @objc private func reload() {
        reloadButton.isEnabled = false
        stopRefreshButton.isEnabled = true
        
        resetEvents()
        
        let gamRequest = GAMRequest()
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            Log.info("Prebid demand fetch for GAM \(resultCode.name())")
            self?.gamBanner.load(gamRequest)
        }
    }
    
    @objc private func stopRefresh() {
        stopRefreshButton.isEnabled = false
        adUnit.stopAutoRefresh()
    }
    
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerViewDidReceiveAd.isEnabled = true
        reloadButton.isEnabled = true
        rootController?.bannerView.constraints.first { $0.firstAttribute == .width }?.constant = bannerView.adSize.size.width
        rootController?.bannerView.constraints.first { $0.firstAttribute == .height }?.constant = bannerView.adSize.size.height
        
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { size in
            guard let bannerView = bannerView as? GAMBannerView else { return }
            bannerView.resize(GADAdSizeFromCGSize(size))
        }, failure: { (error) in
            Log.error("Error occuring during searching for Prebid creative size: \(error)")
        })
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        resetEvents()
        bannerViewDidFailToReceiveAd.isEnabled = true
        Log.error(error.localizedDescription)
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        bannerViewDidRecordImpression.isEnabled = true
    }
    
    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        bannerViewDidRecordClick.isEnabled = true
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        bannerViewWillPresentScreen.isEnabled = true
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        bannerViewWillDismissScreen.isEnabled = true
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        bannerViewDidDismissScreen.isEnabled = true
    }
}
