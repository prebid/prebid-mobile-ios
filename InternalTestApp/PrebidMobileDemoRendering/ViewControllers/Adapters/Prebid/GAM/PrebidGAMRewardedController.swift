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

class PrebidGAMRewardedController: NSObject, AdaptedController, PrebidConfigurableController, RewardedAdUnitDelegate {
    
    var prebidConfigId = ""

    var gamAdUnitId = ""
    
    private var rewardedAdController : RewardedAdUnit?
    
    private weak var adapterViewController: AdapterViewController?
    
    private let rewardedAdDidReceiveAdButton = EventReportContainer()
    private let rewardedAdDidFailToReceiveAdButton = EventReportContainer()
    private let rewardedAdWillPresentAdButton = EventReportContainer()
    private let rewardedAdDidDismissAdButton = EventReportContainer()
    private let rewardedAdWillLeaveApplicationButton = EventReportContainer()
    private let rewardedAdDidClickAdButton = EventReportContainer()
    private let rewardedAdUserDidEarnRewardButton = EventReportContainer()
    
    private let configIdLabel = UILabel()
    
    // MARK: - AdaptedController
    required init(rootController: AdapterViewController) {
        self.adapterViewController = rootController
        super.init()
        
        setupAdapterController()
    }
 
    func configurationController() -> BaseConfigurationController? {
        return BaseConfigurationController(controller: self)
    }
    
    // MARK: - Public Methods
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        let eventHandler = GAMRewardedAdEventHandler(adUnitID: gamAdUnitId)
        rewardedAdController = RewardedAdUnit(configID: prebidConfigId, eventHandler: eventHandler)
        rewardedAdController?.delegate = self
   
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                rewardedAdController?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        // imp[].ext.keywords
        if !AppConfiguration.shared.adUnitContextKeywords.isEmpty {
            for keyword in AppConfiguration.shared.adUnitContextKeywords {
                rewardedAdController?.addContextKeyword(keyword)
            }
        }
        
        // user.data
        if let userData = AppConfiguration.shared.userData {
            let ortbUserData = PBMORTBContentData()
            ortbUserData.ext = [:]
            
            for dataPair in userData {
                ortbUserData.ext?[dataPair.key] = dataPair.value
            }
            
            rewardedAdController?.addUserData([ortbUserData])
        }
        
        // app.content.data
        if let appData = AppConfiguration.shared.appContentData {
            let ortbAppContentData = PBMORTBContentData()
            ortbAppContentData.ext = [:]
            
            for dataPair in appData {
                ortbAppContentData.ext?[dataPair.key] = dataPair.value
            }
            
            rewardedAdController?.addAppContentData([ortbAppContentData])
        }
        
        rewardedAdController?.loadAd()
    }
    
    // MARK: - GADRewardedDelegate
    
    
    func rewardedAdDidReceiveAd(_ rewardedAd: RewardedAdUnit) {
        adapterViewController?.showButton.isEnabled = true
        rewardedAdDidReceiveAdButton.isEnabled = true
    }

    func rewardedAd(_ rewardedAd: RewardedAdUnit, didFailToReceiveAdWithError error: Error?) {
        rewardedAdDidFailToReceiveAdButton.isEnabled = true
    }
    
    func rewardedAdWillPresentAd(_ rewardedAd: RewardedAdUnit) {
        rewardedAdWillPresentAdButton.isEnabled = true
    }
    
    func rewardedAdDidDismissAd(_ rewardedAd: RewardedAdUnit) {
        rewardedAdDidDismissAdButton.isEnabled = true
    }
    
    func rewardedAdWillLeaveApplication(_ rewardedAd: RewardedAdUnit) {
        rewardedAdWillLeaveApplicationButton.isEnabled = true
    }
    
    func rewardedAdDidClickAd(_ rewardedAd: RewardedAdUnit) {
        rewardedAdDidClickAdButton.isEnabled = true
    }
    
    func rewardedAdUserDidEarnReward(_ rewardedAd: RewardedAdUnit, reward: PrebidReward) {
        rewardedAdUserDidEarnRewardButton.isEnabled = true
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
        adapterViewController?.setupAction(rewardedAdDidReceiveAdButton, "rewardedAdDidReceiveAd called")
        adapterViewController?.setupAction(rewardedAdDidFailToReceiveAdButton, "rewardedAdDidFailToReceiveAd called")
        adapterViewController?.setupAction(rewardedAdWillPresentAdButton, "rewardedAdWillPresentAd called")
        adapterViewController?.setupAction(rewardedAdDidDismissAdButton, "rewardedAdDidDismissAd called")
        adapterViewController?.setupAction(rewardedAdWillLeaveApplicationButton, "rewardedAdWillLeaveApplication called")
        adapterViewController?.setupAction(rewardedAdDidClickAdButton, "rewardedAdDidClickAd called")
        adapterViewController?.setupAction(rewardedAdUserDidEarnRewardButton, "rewardedAdUserDidEarnReward called")
    }
    
    @IBAction func showButtonClicked() {
        if let rewardedAdController = rewardedAdController, rewardedAdController.isReady {
            adapterViewController?.showButton.isEnabled = false
            rewardedAdController.show(from: adapterViewController!)
        }
    }
}
