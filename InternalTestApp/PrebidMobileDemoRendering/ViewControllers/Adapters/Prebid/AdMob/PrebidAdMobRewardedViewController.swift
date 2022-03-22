/*   Copyright 2018-2021 Prebid.org, Inc.
 
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

class PrebidAdMobRewardedViewController: NSObject, AdaptedController, PrebidConfigurableController, GADFullScreenContentDelegate {
    
    var prebidConfigId = ""
    var adMobAdUnitId = ""
    
    private weak var adapterViewController: AdapterViewController?
    
    private var rewardedAd: GADRewardedAd?
    
    private let adDidReceiveButton = EventReportContainer()
    private let adDidFailToReceiveButton = EventReportContainer()
    private let adDidFailToPresentFullScreenContentWithErrorButton = EventReportContainer()
    private let adDidPresentFullScreenContentButton = EventReportContainer()
    private let adWillDismissFullScreenContentButton = EventReportContainer()
    private let adDidDismissFullScreenContentButton = EventReportContainer()
    private let adDidRecordImpressionButton = EventReportContainer()
    
    private let configIdLabel = UILabel()
    
    private var adUnit: MediationRewardedAdUnit?
    private var mediationDelegate: AdMobMediationRewardedUtils?
    
    var request = GADRequest()
    
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
        
        mediationDelegate = AdMobMediationRewardedUtils(gadRequest: request)
        
        adUnit = MediationRewardedAdUnit(configId: prebidConfigId, mediationDelegate: mediationDelegate!)
        
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        if let userData = AppConfiguration.shared.userData {
            for dataPair in userData {
                let appData = PBMORTBContentData()
                appData.ext = [dataPair.key: dataPair.value]
                adUnit?.addUserData([appData])
            }
        }
        
        if let appData = AppConfiguration.shared.appContentData {
            for dataPair in appData {
                let appData = PBMORTBContentData()
                appData.ext = [dataPair.key: dataPair.value]
                adUnit?.addAppContentData([appData])
            }
        }
        
        adUnit?.fetchDemand { [weak self] result in
            guard let self = self else { return }
            GADRewardedAd.load(withAdUnitID: self.adMobAdUnitId, request: self.request) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    Log.error(error.localizedDescription)
                    self.resetEvents()
                    self.adDidFailToReceiveButton.isEnabled = true
                    return
                }
                self.rewardedAd = ad
                self.rewardedAd?.fullScreenContentDelegate = self
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
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adDidPresentFullScreenContentButton.isEnabled = true
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adWillDismissFullScreenContentButton.isEnabled = true
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        adDidDismissFullScreenContentButton.isEnabled = true
        rewardedAd = nil
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
        adapterViewController?.setupAction(adDidPresentFullScreenContentButton, "adDidPresentFullScreenContent called")
        adapterViewController?.setupAction(adWillDismissFullScreenContentButton, "adWillDismissFullScreenContent called")
        adapterViewController?.setupAction(adDidDismissFullScreenContentButton, "adDidDismissFullScreenContent called")
        adapterViewController?.setupAction(adDidRecordImpressionButton, "adDidRecordImpression called")
    }
    
    private func resetEvents() {
        adDidReceiveButton.isEnabled = false
        adDidFailToReceiveButton.isEnabled = false
        adDidFailToPresentFullScreenContentWithErrorButton.isEnabled = false
        adDidPresentFullScreenContentButton.isEnabled = false
        adWillDismissFullScreenContentButton.isEnabled = false
        adDidDismissFullScreenContentButton.isEnabled = false
        adDidRecordImpressionButton.isEnabled = false
    }
    
    @IBAction func showButtonClicked() {
        guard let adapterViewController = adapterViewController else { return }
        if rewardedAd != nil {
            rewardedAd?.present(fromRootViewController: adapterViewController, userDidEarnRewardHandler: {
                print("User rewarded")
            })
        }
    }
}
