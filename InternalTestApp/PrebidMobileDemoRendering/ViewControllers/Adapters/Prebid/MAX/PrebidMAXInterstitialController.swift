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
import AppLovinSDK
import PrebidMobile
import PrebidMobileMAXAdapters

class PrebidMAXInterstitialController: NSObject, AdaptedController, PrebidConfigurableController {
    
    var prebidConfigId: String = ""
    var storedAuctionResponse: String?
    
    var maxAdUnitId = ""
    
    var adFormats: Set<AdFormat>?
    
    private var adUnit: MediationInterstitialAdUnit?
    private var mediationDelegate: MAXMediationInterstitialUtils?
    
    private var interstitial: MAInterstitialAd?
    
    private weak var adapterViewController: AdapterViewController?
    
    private let fetchDemandFailedButton = EventReportContainer()
    
    private let didLoadAdButton = EventReportContainer()
    private let didFailToLoadAdForAdUnitIdentifierButton = EventReportContainer()
    private let didFailToDisplayButton = EventReportContainer()
    private let didDisplayAdButton = EventReportContainer()
    private let didHideAdButton = EventReportContainer()
    private let didClickAdButton = EventReportContainer()
    
    private let configIdLabel = UILabel()
    
    // Custom video configuarion
    var maxDuration: Int?
    var closeButtonArea: Double?
    var closeButtonPosition: Position?
    var skipButtonArea: Double?
    var skipButtonPosition: Position?
    var skipDelay: Double?
    
    // MARK: - AdaptedController
    
    required init(rootController: AdapterViewController) {
        self.adapterViewController = rootController
        super.init()
        
        setupAdapterController()
    }
    
    func configurationController() -> BaseConfigurationController? {
        return BaseConfigurationController(controller: self)
    }
    
    func loadAd() {
        if let storedAuctionResponse = storedAuctionResponse {
            Prebid.shared.storedAuctionResponse = storedAuctionResponse
        }
        
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        interstitial = MAInterstitialAd(adUnitIdentifier: maxAdUnitId)
        interstitial?.delegate = self
        
        mediationDelegate = MAXMediationInterstitialUtils(interstitialAd: interstitial!)
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
            
            if result != .prebidDemandFetchSuccess {
                self.fetchDemandFailedButton.isEnabled = true
            }
            
            self.interstitial?.load()
        }
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
        adapterViewController?.setupAction(fetchDemandFailedButton, "fetchDemandFailed called")
        adapterViewController?.setupAction(didLoadAdButton, "didLoadAd called")
        adapterViewController?.setupAction(didFailToLoadAdForAdUnitIdentifierButton, "didFailToLoadAdForAdUnitIdentifier called")
        adapterViewController?.setupAction(didFailToDisplayButton, "didFailToDisplay called")
        adapterViewController?.setupAction(didDisplayAdButton, "didDisplayAd called")
        adapterViewController?.setupAction(didHideAdButton, "didHideAd called")
        adapterViewController?.setupAction(didClickAdButton, "didClickAd called")
    }
    
    private func resetEvents() {
        fetchDemandFailedButton.isEnabled = false
        didLoadAdButton.isEnabled = false
        didFailToLoadAdForAdUnitIdentifierButton.isEnabled = false
        didFailToDisplayButton.isEnabled = false
        didDisplayAdButton.isEnabled = false
        didHideAdButton.isEnabled = false
        didClickAdButton.isEnabled = false
    }
    
    @IBAction func showButtonClicked() {
        if let interstitial = interstitial, interstitial.isReady {
            adapterViewController?.showButton.isEnabled = false
            interstitial.show()
        }
    }
}

extension PrebidMAXInterstitialController: MAAdDelegate {
    func didLoad(_ ad: MAAd) {
        resetEvents()
        didLoadAdButton.isEnabled = true
        adapterViewController?.showButton.isEnabled = true
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        Log.error(error.message)
        resetEvents()
        didFailToLoadAdForAdUnitIdentifierButton.isEnabled = true
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        Log.error(error.message)
        resetEvents()
        didFailToDisplayButton.isEnabled = true
    }
    
    func didDisplay(_ ad: MAAd) {
        didDisplayAdButton.isEnabled = true
    }
    
    func didHide(_ ad: MAAd) {
        didHideAdButton.isEnabled = true
    }
    
    func didClick(_ ad: MAAd) {
        didClickAdButton.isEnabled = true
    }
}
