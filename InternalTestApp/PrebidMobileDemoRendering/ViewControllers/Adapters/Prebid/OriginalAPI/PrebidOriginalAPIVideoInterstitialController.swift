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

class PrebidOriginalAPIVideoInterstitialController:
    NSObject,
    AdaptedController,
    PrebidConfigurableBannerController,
    GADFullScreenContentDelegate {
    
    weak var rootController: AdapterViewController?
    var prebidConfigId = ""
    var adUnitID = ""
    
    var refreshInterval: TimeInterval = 0
    
    // Prebid
    private var adUnit: VideoInterstitialAdUnit!
    
    // GAM
    private var gamInterstitial: GAMInterstitialAd!
    
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
        
        adUnit = VideoInterstitialAdUnit(configId: prebidConfigId)
        
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
         
        let gamRequest = GAMRequest()
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            Log.info("Prebid demand fetch for GAM \(resultCode.name())")
            guard let self = self else { return }
            GAMInterstitialAd.load(withAdManagerAdUnitID: self.adUnitID, request: gamRequest) { [weak self] ad, error in
                guard let self = self else { return }
                
                if let error = error {
                    Log.error("Failed to load interstitial ad with error: \(error.localizedDescription)")
                } else if let ad = ad {
                    self.gamInterstitial = ad
                    self.gamInterstitial.fullScreenContentDelegate = self
                    
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
        if let gamInterstitial = gamInterstitial {
            rootController?.showButton.isEnabled = false
            gamInterstitial.present(fromRootViewController: rootController!)
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        adDidFailToPresentFullScreenContentWithError.isEnabled = true
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        adDidRecordClick.isEnabled = true
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        adDidRecordImpression.isEnabled = true
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adWillPresentFullScreenContent.isEnabled = true
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adWillDismissFullScreenContent.isEnabled = true
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adDidDismissFullScreenContent.isEnabled = true
    }
}
