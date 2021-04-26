//
//  PrebidGAMRewardedController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PrebidMobileGAMEventHandlers

class PrebidGAMRewardedController: NSObject, AdaptedController, PrebidConfigurableController, PBMRewardedAdUnitDelegate {
    
    var prebidConfigId = ""
    var gamAdUnitId = ""
    
    private var rewardedAdController : PBMRewardedAdUnit?
    
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
        
        let eventHandler = PBMGAMRewardedEventHandler(adUnitID: gamAdUnitId)
        rewardedAdController = PBMRewardedAdUnit(configId: prebidConfigId, eventHandler: eventHandler)
        rewardedAdController?.delegate = self
        
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                rewardedAdController?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        rewardedAdController?.loadAd()
    }
    
    // MARK: - GADRewardedDelegate
    
    
    func rewardedAdDidReceiveAd(_ rewardedAd: PBMRewardedAdUnit) {
        adapterViewController?.showButton.isEnabled = true
        rewardedAdDidReceiveAdButton.isEnabled = true
    }

    func rewardedAd(_ rewardedAd: PBMRewardedAdUnit, didFailToReceiveAdWithError error: Error?) {
        rewardedAdDidFailToReceiveAdButton.isEnabled = true
    }
    
    func rewardedAdWillPresentAd(_ rewardedAd: PBMRewardedAdUnit) {
        rewardedAdWillPresentAdButton.isEnabled = true
    }
    
    func rewardedAdDidDismissAd(_ rewardedAd: PBMRewardedAdUnit) {
        rewardedAdDidDismissAdButton.isEnabled = true
    }
    
    func rewardedAdWillLeaveApplication(_ rewardedAd: PBMRewardedAdUnit) {
        rewardedAdWillLeaveApplicationButton.isEnabled = true
    }
    
    func rewardedAdDidClickAd(_ rewardedAd: PBMRewardedAdUnit) {
        rewardedAdDidClickAdButton.isEnabled = true
    }
    
    func rewardedAdUserDidEarnReward(_ rewardedAd: PBMRewardedAdUnit) {
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
