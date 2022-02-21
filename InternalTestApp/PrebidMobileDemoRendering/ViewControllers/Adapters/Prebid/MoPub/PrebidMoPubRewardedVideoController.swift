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

class PrebidMoPubRewardedVideoController: NSObject, AdaptedController, PrebidConfigurableController, MPRewardedVideoDelegate {
    
    var prebidConfigId = ""
    var moPubAdUnitId = ""
    
    weak var adapterViewController: AdapterViewController?

    private let rewardedVideoAdDidLoadButton = EventReportContainer()
    private let rewardedVideoAdDidFailToLoadButton = EventReportContainer()
    private let rewardedVideoAdWillAppearButton = EventReportContainer()
    private let rewardedVideoAdDidAppearButton = EventReportContainer()
    private let rewardedVideoAdWillDisappearButton = EventReportContainer()
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
        setProccesArgumentParser()
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
        
        adUnit?.fetchDemand() { [weak self] result in
            guard let self = self else {
                return
            }
            
            MPRewardedVideo.setDelegate(self, forAdUnitId: self.moPubAdUnitId)
            MPRewardedVideo.loadAd(withAdUnitID: self.moPubAdUnitId,
                                   keywords: bidInfoWrapper.keywords as String?,
                                   userDataKeywords: nil,
                                   customerId: "testCustomerId",
                                   mediationSettings: [],
                                   localExtras: bidInfoWrapper.localExtras)
        }
    }

    // MARK: MPRewardedVideoDelegate
    
    func rewardedVideoAdDidLoad(forAdUnitID adUnitID: String!) {
        rewardedVideoAdDidLoadButton.isEnabled = true
        
        adapterViewController?.activityIndicator.stopAnimating()
        adapterViewController?.showButton.isHidden = false
        adapterViewController?.showButton.isEnabled = true
    }
    
    func rewardedVideoAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
        rewardedVideoAdDidFailToLoadButton.isEnabled = true
        
        adapterViewController?.activityIndicator.stopAnimating()
    }
    
    func rewardedVideoAdWillAppear(forAdUnitID adUnitID: String!) {
        rewardedVideoAdWillAppearButton.isEnabled = true
    }
    
    func rewardedVideoAdDidAppear(forAdUnitID adUnitID: String!) {
        rewardedVideoAdDidAppearButton.isEnabled = true
    }
    
    func rewardedVideoAdWillDisappear(forAdUnitID adUnitID: String!) {
        rewardedVideoAdWillDisappearButton.isEnabled = true
    }
    
    func rewardedVideoAdDidDisappear(forAdUnitID adUnitID: String!) {
        rewardedVideoAdDidDisappearButton.isEnabled = true
        
        adapterViewController?.showButton.isHidden = true
    }
    
    func rewardedVideoAdDidExpire(forAdUnitID adUnitID: String!) {
        rewardedVideoAdDidExpireButton.isEnabled = true
        
        adapterViewController?.showButton.isHidden = true
        adapterViewController?.activityIndicator.stopAnimating()
    }
    
    func rewardedVideoAdDidReceiveTapEvent(forAdUnitID adUnitID: String!) {
        rewardedVideoAdDidReceiveTapEventButton.isEnabled = true
    }
    
    func rewardedVideoAdShouldReward(forAdUnitID adUnitID: String!, reward: MPRewardedVideoReward!) {
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
        adapterViewController?.showButton.isEnabled = false
        adapterViewController?.showButton.addTarget(self, action:#selector(self.showButtonClicked), for: .touchUpInside)
    }
    
    private func setupActions() {
        adapterViewController?.setupAction(rewardedVideoAdDidLoadButton, "rewardedVideoAdDidLoad called")
        adapterViewController?.setupAction(rewardedVideoAdDidFailToLoadButton, "rewardedVideoAdDidFailToLoad called")
        adapterViewController?.setupAction(rewardedVideoAdWillAppearButton, "rewardedVideoAdWillAppearButton called")
        adapterViewController?.setupAction(rewardedVideoAdDidAppearButton, "rewardedVideoAdDidAppearButton called")
        adapterViewController?.setupAction(rewardedVideoAdWillDisappearButton, "rewardedVideoAdWillDisappearButton called")
        adapterViewController?.setupAction(rewardedVideoAdDidDisappearButton, "rewardedVideoAdDidDisappear called")
        adapterViewController?.setupAction(rewardedVideoAdDidExpireButton, "rewardedVideoAdDidExpire called")
        adapterViewController?.setupAction(rewardedVideoAdDidReceiveTapEventButton, "rewardedVideoAdDidReceiveTapEvent called")
        adapterViewController?.setupAction(rewardedVideoAdShouldRewardButton, "rewardedVideoAdShouldReward called")
    }
    
    @IBAction func showButtonClicked() {
        if MPRewardedVideo.hasAdAvailable(forAdUnitID: moPubAdUnitId) {
            let rewards = MPRewardedVideo.availableRewards(forAdUnitID: moPubAdUnitId)
            guard let reward = rewards?.first as? MPRewardedVideoReward else {
                return
            }
            adapterViewController?.showButton.isEnabled = false
            MPRewardedVideo.presentAd(forAdUnitID: moPubAdUnitId, from: adapterViewController, with: reward, customData: nil)
        }
    }
    
    private func setProccesArgumentParser() {
        let processArgumentsParser = ProcessArgumentsParser()
        processArgumentsParser.addOption("ADD_USER_DATA", paramsCount: 2) { [weak self] params in
            let userData = PBMORTBContentData()
            userData.ext = [params[0]: params[1]]
            self?.adUnit?.addUserData([userData])
        }
        
        processArgumentsParser.addOption("ADD_APP_CONTEXT", paramsCount: 2) { [weak self] params in
            let appData = PBMORTBContentData()
            appData.ext = [params[0]: params[1]]
            self?.adUnit?.addAppContentData([appData])
        }
        processArgumentsParser.parseProcessArguments(ProcessInfo.processInfo.arguments)
    }
}
