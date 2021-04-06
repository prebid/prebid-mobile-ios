//
//  PrebidInterstitialController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import GoogleMobileAds

class PrebidInterstitialController: NSObject, AdaptedController, PrebidConfigurableController, OXAInterstitialAdUnitDelegate {
    
    var prebidConfigId = ""
    var adFormat: OXAAdFormat?
    
    private var interstitialController : OXAInterstitialAdUnit?
    
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
    }
    
    func configurationController() -> BaseConfigurationController? {
        return BaseConfigurationController(controller: self)
    }
    
    // MARK: - Public Methods
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        interstitialController = OXAInterstitialAdUnit(configId: prebidConfigId,
                                                       minSizePercentage: CGSize(width: 30, height: 30))
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
    
    
    func interstitialDidReceiveAd(_ interstitial: OXAInterstitialAdUnit) {
        adapterViewController?.showButton.isEnabled = true
        interstitialDidReceiveAdButton.isEnabled = true
    }

    func interstitial(_ interstitial: OXAInterstitialAdUnit, didFailToReceiveAdWithError error: Error?) {
        interstitialDidFailToReceiveAdButton.isEnabled = true
    }
    
    func interstitialWillPresentAd(_ interstitial: OXAInterstitialAdUnit) {
        interstitialWillPresentAdButton.isEnabled = true
    }
    
    func interstitialDidDismissAd(_ interstitial: OXAInterstitialAdUnit) {
        interstitialDidDismissAdButton.isEnabled = true
    }
    
    func interstitialWillLeaveApplication(_ interstitial: OXAInterstitialAdUnit) {
        interstitialWillLeaveApplicationButton.isEnabled = true
    }
    
    func interstitialDidClickAd(_ interstitial: OXAInterstitialAdUnit) {
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
