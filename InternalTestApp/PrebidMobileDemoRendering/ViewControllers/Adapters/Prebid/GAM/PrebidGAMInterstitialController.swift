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
import PrebidMobileGAMEventHandlers

class PrebidGAMInterstitialController: NSObject, AdaptedController, PrebidConfigurableController, InterstitialAdUnitDelegate {
    
    var prebidConfigId = ""
    var gamAdUnitId = ""
    var adFormat: AdFormat?
    
    private var interstitialController : InterstitialRenderingAdUnit?
    
    private weak var adapterViewController: AdapterViewController?
    
    private let interstitialDidReceiveAdButton = EventReportContainer()
    private let interstitialDidFailToReceiveAdButton = EventReportContainer()
    private let interstitialWillPresentAdButton = EventReportContainer()
    private let interstitialDidDismissAdButton = EventReportContainer()
    private let interstitialWillLeaveApplicationButton = EventReportContainer()
    private let interstitialDidClickAdButton = EventReportContainer()
    
    private let configIdLabel = UILabel()
    
    // MARK: - AdaptedController
    required init(rootController: AdapterViewController) {
        self.adapterViewController = rootController
        super.init()
        
        setupAdapterController()
        setProccesArgumentParser()
    }
    
    func configurationController() -> BaseConfigurationController? {
        return BaseConfigurationController(controller: self)
    }
    
    // MARK: - Public Methods
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        let eventHandler = GAMInterstitialEventHandler(adUnitID: gamAdUnitId)
        interstitialController = InterstitialRenderingAdUnit(configID: prebidConfigId,
                                                    minSizePercentage: CGSize(width: 30, height: 30),
                                                    eventHandler: eventHandler)
        interstitialController?.delegate = self
        if let adFormat = adFormat {
            interstitialController?.adFormat = adFormat
        }
        
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                interstitialController?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        interstitialController?.loadAd()
    }
    
    // MARK: - GADInterstitialDelegate
    
    
    func interstitialDidReceiveAd(_ interstitial: InterstitialRenderingAdUnit) {
        adapterViewController?.showButton.isEnabled = true
        interstitialDidReceiveAdButton.isEnabled = true
    }

    func interstitial(_ interstitial: InterstitialRenderingAdUnit, didFailToReceiveAdWithError error: Error?) {
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
    
    private func setProccesArgumentParser() {
        let processArgumentsParser = ProcessArgumentsParser()
        processArgumentsParser.addOption("ADD_USER_DATA", paramsCount: 2) { [weak self] params in
            let userData = PBMORTBContentData()
            userData.ext = [params[0]: params[1]]
            self?.interstitialController?.addUserData([userData])
        }
        
        processArgumentsParser.addOption("ADD_APP_CONTEXT", paramsCount: 2) { [weak self] params in
            let appData = PBMORTBContentData()
            appData.ext = [params[0]: params[1]]
            self?.interstitialController?.addAppContentData([appData])
        }
        processArgumentsParser.parseProcessArguments(ProcessInfo.processInfo.arguments)
    }
}
