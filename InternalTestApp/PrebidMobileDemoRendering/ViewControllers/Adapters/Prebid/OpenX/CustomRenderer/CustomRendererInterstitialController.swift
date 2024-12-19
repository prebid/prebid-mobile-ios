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

class CustomRendererInterstitialController:
    NSObject,
    AdaptedController,
    PrebidConfigurableController,
    InterstitialAdUnitDelegate {
    
    var prebidConfigId = ""
    var storedAuctionResponse: String?

    var adFormats: Set<AdFormat>?
    
    private var interstitialController : InterstitialRenderingAdUnit?
    private let sampleCustomRenderer = SampleRenderer()
    
    private weak var adapterViewController: AdapterViewController?
    
    private let interstitialDidReceiveAdButton = EventReportContainer()
    private let interstitialDidFailToReceiveAdButton = EventReportContainer()
    private let interstitialWillPresentAdButton = EventReportContainer()
    private let interstitialDidDismissAdButton = EventReportContainer()
    private let interstitialWillLeaveApplicationButton = EventReportContainer()
    private let interstitialDidClickAdButton = EventReportContainer()
    
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
        Prebid.registerPluginRenderer(sampleCustomRenderer)
        super.init()
        
        setupAdapterController()
    }
    
    deinit {
        Targeting.shared.sourceapp = nil
        Prebid.unregisterPluginRenderer(sampleCustomRenderer)
    }
    
    func configurationController() -> BaseConfigurationController? {
        return BaseConfigurationController(controller: self)
    }
    
    // MARK: - Public Methods
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        if let storedAuctionResponse = storedAuctionResponse {
            Prebid.shared.storedAuctionResponse = storedAuctionResponse
        }

        interstitialController = InterstitialRenderingAdUnit(
            configID: prebidConfigId,
            minSizePercentage: CGSize(width: 30, height: 30)
        )
        
        interstitialController?.delegate = self
        
        // Custom video configuarion
        if let maxDuration = maxDuration {
            interstitialController?.videoParameters.maxDuration = SingleContainerInt(integerLiteral: maxDuration)
        }
        
        if let closeButtonArea = closeButtonArea {
            interstitialController?.closeButtonArea = closeButtonArea
        }
        
        if let closeButtonPosition = closeButtonPosition {
            interstitialController?.closeButtonPosition = closeButtonPosition
        }
        
        if let skipButtonArea = skipButtonArea {
            interstitialController?.skipButtonArea = skipButtonArea
        }
        
        if let skipButtonPosition = skipButtonPosition {
            interstitialController?.skipButtonPosition = skipButtonPosition
        }
        
        if let skipDelay = skipDelay {
            interstitialController?.skipDelay = skipDelay
        }
        
        if let adFormats = adFormats {
            interstitialController?.adFormats = adFormats
        }
        
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                interstitialController?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        // imp[].ext.keywords
        if !AppConfiguration.shared.adUnitContextKeywords.isEmpty {
            for keyword in AppConfiguration.shared.adUnitContextKeywords {
                interstitialController?.addContextKeyword(keyword)
            }
        }
        
        // user.data
        if let userData = AppConfiguration.shared.userData {
            let ortbUserData = PBMORTBContentData()
            ortbUserData.ext = [:]
            
            for dataPair in userData {
                ortbUserData.ext?[dataPair.key] = dataPair.value
            }
            
            interstitialController?.addUserData([ortbUserData])
        }
        
        // app.content.data
        if let appData = AppConfiguration.shared.appContentData {
            let ortbAppContentData = PBMORTBContentData()
            ortbAppContentData.ext = [:]
            
            for dataPair in appData {
                ortbAppContentData.ext?[dataPair.key] = dataPair.value
            }
            
            interstitialController?.addAppContentData([ortbAppContentData])
        }
        
        interstitialController?.loadAd()
    }
    
    // MARK: - GADInterstitialDelegate
    
    
    func interstitialDidReceiveAd(_ interstitial: InterstitialRenderingAdUnit) {
        adapterViewController?.showButton.isEnabled = true
        interstitialDidReceiveAdButton.isEnabled = true
    }

    func interstitial(_ interstitial: InterstitialRenderingAdUnit,
                      didFailToReceiveAdWithError error: Error?) {
        interstitialDidFailToReceiveAdButton.isEnabled = true
    }
    
    func interstitialWillPresentAd(_ interstitial: InterstitialRenderingAdUnit) {
        interstitialWillPresentAdButton.isEnabled = true
    }
    
    func interstitialDidDismissAd(_ interstitial: InterstitialRenderingAdUnit) {
        interstitialDidDismissAdButton.isEnabled = true
    }
    
    func interstitialWillLeaveApplication(_ interstitial: InterstitialRenderingAdUnit) {
        interstitialWillLeaveApplicationButton.isEnabled = true
    }
    
    func interstitialDidClickAd(_ interstitial: InterstitialRenderingAdUnit) {
        interstitialDidClickAdButton.isEnabled = true
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
        adapterViewController?.setupAction(interstitialDidReceiveAdButton, "interstitialDidReceiveAd called")
        adapterViewController?.setupAction(interstitialDidFailToReceiveAdButton, "interstitialDidFailToReceiveAd called")
        adapterViewController?.setupAction(interstitialWillPresentAdButton, "interstitialWillPresentAd called")
        adapterViewController?.setupAction(interstitialDidDismissAdButton, "interstitialDidDismissAd called")
        adapterViewController?.setupAction(interstitialWillLeaveApplicationButton, "interstitialWillLeaveApplication called")
        adapterViewController?.setupAction(interstitialDidClickAdButton, "interstitialDidClickAd called")
    }
    
    @IBAction func showButtonClicked() {
        if let interstitialController = interstitialController, interstitialController.isReady {
            adapterViewController?.showButton.isEnabled = false
            interstitialController.show(from: adapterViewController!)
        }
    }
}
