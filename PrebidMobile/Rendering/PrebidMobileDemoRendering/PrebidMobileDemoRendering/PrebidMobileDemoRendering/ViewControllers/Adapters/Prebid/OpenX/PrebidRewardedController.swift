//
//  PrebidRewardedController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PrebidMobileRendering

class PrebidRewardedController: NSObject, AdaptedController, RewardedAdUnitDelegate {
    
    var prebidConfigId = ""
    
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
    
    // MARK: - Public Methods
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        rewardedAdController = RewardedAdUnit(configID: prebidConfigId)
        rewardedAdController?.delegate = self
        
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                rewardedAdController?.addContextData(dataPair.value, forKey: dataPair.key)
            }
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
    
    func rewardedAdUserDidEarnReward(_ rewardedAd: RewardedAdUnit) {
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
