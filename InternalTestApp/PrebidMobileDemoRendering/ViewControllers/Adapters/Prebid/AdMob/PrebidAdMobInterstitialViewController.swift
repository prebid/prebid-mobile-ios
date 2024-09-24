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
import GoogleMobileAds
import PrebidMobile
import PrebidMobileAdMobAdapters

class PrebidAdMobInterstitialViewController: NSObject, AdaptedController, PrebidConfigurableController, GADFullScreenContentDelegate {
    
    var prebidConfigId = ""
    var storedAuctionResponse: String?

    var adMobAdUnitId = ""
    
    var adFormats: Set<AdFormat>?
    
    private weak var adapterViewController: AdapterViewController?
    
    private var interstitial: GADInterstitialAd?
    
    private let adDidReceiveButton = EventReportContainer()
    private let adDidFailToReceiveButton = EventReportContainer()
    private let adDidFailToPresentFullScreenContentWithErrorButton = EventReportContainer()
    private let adWillDismissFullScreenContentButton = EventReportContainer()
    private let adDidDismissFullScreenContentButton = EventReportContainer()
    private let adDidRecordImpressionButton = EventReportContainer()
    
    private let configIdLabel = UILabel()
    
    private var adUnit: MediationInterstitialAdUnit?
    private var mediationDelegate: AdMobMediationInterstitialUtils?
    
    var request = GADRequest()
    
    // Custom video configuarion
    var maxDuration: Int?
    var closeButtonArea: Double?
    var closeButtonPosition: Position?
    var skipButtonArea: Double?
    var skipButtonPosition: Position?
    var skipDelay: Double?
    
    required init(rootController: AdapterViewController) {
        self.adapterViewController = rootController
        super.init()
        
        setupAdapterController()
    }
    
    func configurationController() -> BaseConfigurationController? {
        return BaseConfigurationController(controller: self)
    }
    
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        if let storedAuctionResponse = storedAuctionResponse {
            Prebid.shared.storedAuctionResponse = storedAuctionResponse
        }
        
        mediationDelegate = AdMobMediationInterstitialUtils(gadRequest: request)
        adUnit = MediationInterstitialAdUnit(configId: prebidConfigId,
                                             minSizePercentage: CGSize(width: 30, height: 30),
                                             mediationDelegate: mediationDelegate!)
        
        // Custom video configuarion
        if let maxDuration = maxDuration {
            adUnit?.videoParameters.maxDuration = SingleContainerInt(integerLiteral: maxDuration)
        }
        
        if let closeButtonArea = closeButtonArea {
            adUnit?.closeButtonArea = closeButtonArea
        }
        
        if let closeButtonPosition = closeButtonPosition {
            adUnit?.closeButtonPosition = closeButtonPosition
        }
        
        if let skipButtonArea = skipButtonArea {
            adUnit?.skipButtonArea = skipButtonArea
        }
        
        if let skipButtonPosition = skipButtonPosition {
            adUnit?.skipButtonPosition = skipButtonPosition
        }
        
        if let skipDelay = skipDelay {
            adUnit?.skipDelay = skipDelay
        }
        
        if let adFormats = adFormats {
            adUnit?.adFormats = adFormats
        }
        
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(key: dataPair.value, value: dataPair.key)
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
        
        adUnit?.fetchDemand { [weak self] result in
            guard let self = self else { return }
            GADInterstitialAd.load(withAdUnitID: self.adMobAdUnitId, request: self.request) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    Log.error(error.localizedDescription)
                    self.resetEvents()
                    self.adDidFailToReceiveButton.isEnabled = true
                    return
                }
                self.interstitial = ad
                self.interstitial?.fullScreenContentDelegate = self
                self.adapterViewController?.showButton.isEnabled = true
                self.adDidReceiveButton.isEnabled = true
            }
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Log.error(error.localizedDescription)
        resetEvents()
        adDidFailToPresentFullScreenContentWithErrorButton.isEnabled = true
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adWillDismissFullScreenContentButton.isEnabled = true
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adDidDismissFullScreenContentButton.isEnabled = true
        interstitial = nil
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        adDidRecordImpressionButton.isEnabled = true
    }
    
    // MARK: - Private Methods
    private func setupAdapterController() {
        adapterViewController?.bannerView.isHidden = true
        
        setupShowButton()
        setupActions()
        
        configIdLabel.isHidden = true
        adapterViewController?.actionsView.addArrangedSubview(configIdLabel)
    }
    
    private func setupShowButton() {
        adapterViewController?.showButton.isEnabled = false
        adapterViewController?.showButton.addTarget(self, action:#selector(self.showButtonClicked), for: .touchUpInside)
    }
    
    private func setupActions() {
        adapterViewController?.setupAction(adDidReceiveButton, "adDidReceiveButton called")
        adapterViewController?.setupAction(adDidFailToReceiveButton, "adDidFailToReceiveButton called")
        adapterViewController?.setupAction(adDidFailToPresentFullScreenContentWithErrorButton, "adDidFailToPresentFullScreenContentWithError called")
        adapterViewController?.setupAction(adWillDismissFullScreenContentButton, "adWillDismissFullScreenContent called")
        adapterViewController?.setupAction(adDidDismissFullScreenContentButton, "adDidDismissFullScreenContent called")
        adapterViewController?.setupAction(adDidRecordImpressionButton, "adDidRecordImpression called")
    }
    
    private func resetEvents() {
        adDidReceiveButton.isEnabled = false
        adDidFailToReceiveButton.isEnabled = false
        adDidFailToPresentFullScreenContentWithErrorButton.isEnabled = false
        adWillDismissFullScreenContentButton.isEnabled = false
        adDidDismissFullScreenContentButton.isEnabled = false
        adDidRecordImpressionButton.isEnabled = false
    }
    
    @IBAction func showButtonClicked() {
        guard let adapterViewController = adapterViewController else { return }
        if interstitial != nil {
            adapterViewController.showButton.isEnabled = false
            interstitial?.present(fromRootViewController: adapterViewController)
        }
    }
}
