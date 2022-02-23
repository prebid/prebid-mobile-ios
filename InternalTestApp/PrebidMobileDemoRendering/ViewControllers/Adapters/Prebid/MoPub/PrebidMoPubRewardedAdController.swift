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
import MoPubSDK

import PrebidMobile
import PrebidMobileMoPubAdapters

class PrebidMoPubRewardedAdController: NSObject, AdaptedController, PrebidConfigurableController, MPRewardedAdsDelegate {
    
    var prebidConfigId = ""
    var moPubAdUnitId = ""
    
    weak var adapterViewController: AdapterViewController?

    private let rewardedVideoAdDidLoadButton = EventReportContainer()
    private let rewardedVideoAdDidFailToLoadButton = EventReportContainer()
    private let rewardedVideoAdWillPresentButton = EventReportContainer()
    private let rewardedVideoAdDidPresentButton = EventReportContainer()
    private let rewardedVideoAdWillDismissButton = EventReportContainer()
    private let rewardedVideoAdDidDisappearButton = EventReportContainer()
    private let rewardedVideoAdDidExpireButton = EventReportContainer()
    private let rewardedVideoAdDidReceiveTapEventButton = EventReportContainer()
    private let rewardedVideoAdShouldRewardButton = EventReportContainer()
    
    private let configIdLabel = UILabel()
    
    private var adUnit: MediationRewardedAdUnit?
        
    // MARK: - AdaptedController
    
    required init(rootController: AdapterViewController) {
        adapterViewController = rootController

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
        
        adapterViewController?.activityIndicator.isHidden = true
        adapterViewController?.activityIndicator.startAnimating()
        
        let bidInfoWrapper = MediationBidInfoWrapper()
        
        adUnit = MediationRewardedAdUnit(configId: prebidConfigId,
                                         mediationDelegate: MoPubMediationRewardedUtils(bidInfoWrapper: bidInfoWrapper))
        
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
        
        adUnit?.fetchDemand() { [weak self] result in
            guard let self = self else {
                return
            }
            
            MPRewardedAds.setDelegate(self, forAdUnitId: self.moPubAdUnitId)
            MPRewardedAds.loadRewardedAd(withAdUnitID: self.moPubAdUnitId,
                                         keywords: bidInfoWrapper.keywords as String?,
                                         userDataKeywords: nil,
                                         customerId: "testCustomerId",
                                         mediationSettings: [],
                                         localExtras: bidInfoWrapper.localExtras)
        }
    }
    
    // MARK: MPRewardedAdsDelegate
    
    func rewardedAdDidLoad(forAdUnitID adUnitID: String!) {
        rewardedVideoAdDidLoadButton.isEnabled = true
        
        adapterViewController?.activityIndicator.stopAnimating()
        adapterViewController?.showButton.isHidden = false
        adapterViewController?.showButton.isEnabled = true
    }
    
    func rewardedAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
        rewardedVideoAdDidFailToLoadButton.isEnabled = true
        
        adapterViewController?.activityIndicator.stopAnimating()
    }
    
    func rewardedAdWillPresent(forAdUnitID adUnitID: String!) {
        rewardedVideoAdWillPresentButton.isEnabled = true
    }
    
    func rewardedAdDidPresent(forAdUnitID adUnitID: String!) {
        rewardedVideoAdDidPresentButton.isEnabled = true
    }
    
    func rewardedAdWillDismiss(forAdUnitID adUnitID: String!) {
        rewardedVideoAdWillDismissButton.isEnabled = true
    }
    
    func rewardedAdDidDismiss(forAdUnitID adUnitID: String!) {
        rewardedVideoAdDidDisappearButton.isEnabled = true
        
        adapterViewController?.showButton.isHidden = true
    }
    
    func rewardedAdDidExpire(forAdUnitID adUnitID: String!) {
        rewardedVideoAdDidExpireButton.isEnabled = true
        
        adapterViewController?.showButton.isHidden = true
        adapterViewController?.activityIndicator.stopAnimating()
    }
    
    func rewardedAdDidReceiveTapEvent(forAdUnitID adUnitID: String!) {
        rewardedVideoAdDidReceiveTapEventButton.isEnabled = true
    }
    
    func rewardedAdShouldReward(forAdUnitID adUnitID: String!, reward: MPReward!) {
        rewardedVideoAdShouldRewardButton.isEnabled = true
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
        adapterViewController?.showButton.isEnabled = MPRewardedAds.hasAdAvailable(forAdUnitID: moPubAdUnitId)
        adapterViewController?.showButton.addTarget(self, action:#selector(self.showButtonClicked), for: .touchUpInside)
    }
    
    private func setupActions() {
        adapterViewController?.setupAction(rewardedVideoAdDidLoadButton, "rewardedVideoAdDidLoad called")
        adapterViewController?.setupAction(rewardedVideoAdDidFailToLoadButton, "rewardedVideoAdDidFailToLoad called")
        adapterViewController?.setupAction(rewardedVideoAdWillPresentButton, "rewardedAdWillPresent called")
        adapterViewController?.setupAction(rewardedVideoAdDidPresentButton, "rewardedAdDidPresent called")
        adapterViewController?.setupAction(rewardedVideoAdWillDismissButton, "rewardedAdWillDismiss called")
        adapterViewController?.setupAction(rewardedVideoAdDidDisappearButton, "rewardedAdDidDismiss called")
        adapterViewController?.setupAction(rewardedVideoAdDidExpireButton, "rewardedVideoAdDidExpire called")
        adapterViewController?.setupAction(rewardedVideoAdDidReceiveTapEventButton, "rewardedVideoAdDidReceiveTapEvent called")
        adapterViewController?.setupAction(rewardedVideoAdShouldRewardButton, "rewardedVideoAdShouldReward called")
    }
    
    @IBAction func showButtonClicked() {
        
        
        if MPRewardedAds.hasAdAvailable(forAdUnitID: moPubAdUnitId) {
            let rewards = MPRewardedAds.availableRewards(forAdUnitID: moPubAdUnitId)
            guard let reward = rewards?.first as? MPReward else {
                return
            }
            adapterViewController?.showButton.isEnabled = false
            MPRewardedAds.presentRewardedAd(forAdUnitID: moPubAdUnitId,
                                            from: adapterViewController,
                                            with: reward)
        }
    }
}
