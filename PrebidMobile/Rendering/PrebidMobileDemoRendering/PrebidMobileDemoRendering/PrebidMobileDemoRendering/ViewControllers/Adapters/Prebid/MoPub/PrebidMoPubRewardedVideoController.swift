//
//  PrebidMoPubAdapterRewardedVideoViewController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import UIKit
import MoPubSDK
import PrebidMobileRendering

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
    
    private var adUnit: MoPubRewardedAdUnit?
    
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
        
        adUnit = MoPubRewardedAdUnit(configId: prebidConfigId)
        
        let bidInfoWrapper = MoPubBidInfoWrapper()
        
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        adUnit?.fetchDemand(with: bidInfoWrapper) { [weak self] result in
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
}
