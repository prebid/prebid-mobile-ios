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

class PrebidOriginalAPIVideoRewardedController:
    NSObject,
    AdaptedController,
    PrebidConfigurableBannerController,
    FullScreenContentDelegate {
    
    weak var rootController: AdapterViewController?
    var prebidConfigId = ""
    var adUnitID = ""
    
    var refreshInterval: TimeInterval = 0
    
    var supportSKOverlay = false
    
    // Prebid
    private var adUnit: RewardedVideoAdUnit!
    
    // GAM
    private var gamRewarded: RewardedAd!
    
    private let adDidFailToPresentFullScreenContentWithError = EventReportContainer()
    private let adDidRecordClick = EventReportContainer()
    private let adDidRecordImpression = EventReportContainer()
    private let adWillPresentFullScreenContent = EventReportContainer()
    private let adWillDismissFullScreenContent = EventReportContainer()
    private let adDidDismissFullScreenContent = EventReportContainer()
    
    private let configIdLabel = UILabel()
    
    required init(rootController: AdapterViewController) {
        super.init()
        self.rootController = rootController
        
        setupAdapterController()
    }
    
    func configurationController() -> BaseConfigurationController? {
        return BaseConfigurationController(controller: self)
    }
    
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        adUnit = RewardedVideoAdUnit(configId: prebidConfigId)
        adUnit.supportSKOverlay = supportSKOverlay
        
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addExtData(key: dataPair.key, value: dataPair.value)
            }
        }
        
        // imp[].ext.keywords
        if !AppConfiguration.shared.adUnitContextKeywords.isEmpty {
            for keyword in AppConfiguration.shared.adUnitContextKeywords {
                adUnit?.addExtKeyword(keyword)
            }
        }
         
        let gamRequest = AdManagerRequest()
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            Log.info("Prebid demand fetch for GAM \(resultCode.name())")
            guard let self = self else { return }
            RewardedAd.load(with: self.adUnitID, request: gamRequest) { [weak self] ad, error in
                guard let self = self else { return }
                
                if let error = error {
                    Log.error("Failed to load rewarded ad with error: \(error.localizedDescription)")
                } else if let ad = ad {
                    self.gamRewarded = ad
                    self.gamRewarded.fullScreenContentDelegate = self
                    
                    self.rootController?.showButton.isEnabled = true
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAdapterController() {
        rootController?.bannerView.isHidden = true
        
        setupShowButton()
        setupActions()
        
        configIdLabel.isHidden = true
        rootController?.actionsView.addArrangedSubview(configIdLabel)
    }
    
    private func setupShowButton() {
        rootController?.showButton.isEnabled = false
        rootController?.showButton.addTarget(self, action:#selector(self.showButtonClicked), for: .touchUpInside)
    }
    
    private func setupActions() {
        rootController?.setupAction(adDidFailToPresentFullScreenContentWithError, "adDidFailToPresentContent called")
        rootController?.setupAction(adDidRecordClick, "adDidRecordClick called")
        rootController?.setupAction(adDidRecordImpression, "adDidRecordImpression called")
        rootController?.setupAction(adWillPresentFullScreenContent, "adWillPresentFullScreenContent called")
        rootController?.setupAction(adWillDismissFullScreenContent, "adWillDismissFullScreenContent called")
        rootController?.setupAction(adDidDismissFullScreenContent, "adDidDismissFullScreenContent called")
    }
    
    @IBAction func showButtonClicked() {
        if let gamRewarded = gamRewarded {
            rootController?.showButton.isEnabled = false
            if supportSKOverlay {
                adUnit.activateSKOverlayIfAvailable()
            }
            
            gamRewarded.present(from: rootController!) {}
        }
    }
    
    // MARK: - FullScreenContentDelegate
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        adDidFailToPresentFullScreenContentWithError.isEnabled = true
    }
    
    func adDidRecordClick(_ ad: FullScreenPresentingAd) {
        adDidRecordClick.isEnabled = true
    }
    
    func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
        adDidRecordImpression.isEnabled = true
    }
    
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        adWillPresentFullScreenContent.isEnabled = true
    }
    
    func adWillDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        adWillDismissFullScreenContent.isEnabled = true
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        adDidDismissFullScreenContent.isEnabled = true
        adUnit.dismissSKOverlayIfAvailable()
    }
}
