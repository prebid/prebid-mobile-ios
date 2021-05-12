//
//  PrebidMoPubAdapterInterstitialViewController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import MoPubSDK

class PrebidMoPubInterstitialController: NSObject, AdaptedController, PrebidConfigurableController, MPInterstitialAdControllerDelegate {
    
    var prebidConfigId = ""
    var moPubAdUnitId = ""
    var adFormat: PBMAdFormat?

    private var interstitialController : MPInterstitialAdController?
    
    private weak var adapterViewController: AdapterViewController?

    private let interstitialDidLoadAdButton = EventReportContainer()
    private let interstitialDidFailButton = EventReportContainer()
    private let interstitialWillAppearButton = EventReportContainer()
    private let interstitialDidAppearButton = EventReportContainer()
    private let interstitialWillDisappearButton = EventReportContainer()
    private let interstitialDidDisappearButton = EventReportContainer()
    private let interstitialDidExpireButton = EventReportContainer()
    private let interstitialDidReceiveTapEventButton = EventReportContainer()
    
    private let configIdLabel = UILabel()
    
    private var adUnit: PBMMoPubInterstitialAdUnit?
    
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
        
        interstitialController = MPInterstitialAdController.init(forAdUnitId: self.moPubAdUnitId)
        interstitialController?.delegate = self
        
        adUnit = PBMMoPubInterstitialAdUnit(configId: prebidConfigId, minSizePercentage: CGSize(width: 30, height: 30))
        if let adFormat = adFormat {
            adUnit?.adFormat = adFormat
        }
        
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        adUnit?.fetchDemand(with: interstitialController!) { [weak self] result in
            self?.interstitialController?.loadAd()
        }
    }
    
    // MARK: - MPInterstitialAdControllerDelegate
    func interstitialDidLoadAd(_ interstitial: MPInterstitialAdController!) {
        if interstitial.ready {
            interstitialDidLoadAdButton.isEnabled = true
            adapterViewController?.showButton.isEnabled = true
        }
    }
    
    func interstitialDidFail(toLoadAd interstitial: MPInterstitialAdController!) {
        interstitialDidFailButton.isEnabled = true
    }
    
    func interstitialWillAppear(_ interstitial: MPInterstitialAdController!) {
        interstitialWillAppearButton.isEnabled = true
    }
    
    func interstitialDidAppear(_ interstitial: MPInterstitialAdController!) {
        interstitialDidAppearButton.isEnabled = true
    }
    
    func interstitialWillDisappear(_ interstitial: MPInterstitialAdController!) {
        interstitialController?.loadAd()
        interstitialWillDisappearButton.isEnabled = true
    }
    
    func interstitialDidDisappear(_ interstitial: MPInterstitialAdController!) {
        interstitialDidDisappearButton.isEnabled = true
        adapterViewController?.showButton.isEnabled = false
    }
    
    func interstitialDidExpire(_ interstitial: MPInterstitialAdController!) {
        interstitialDidExpireButton.isEnabled = true
    }
    
    func interstitialDidReceiveTapEvent(_ interstitial: MPInterstitialAdController!) {
        interstitialDidReceiveTapEventButton.isEnabled = true
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
        adapterViewController?.setupAction(interstitialDidLoadAdButton, "interstitialDidLoadAd called")
        adapterViewController?.setupAction(interstitialDidFailButton, "interstitialDidFail called")
        adapterViewController?.setupAction(interstitialWillAppearButton, "interstitialWillAppear called")
        adapterViewController?.setupAction(interstitialDidAppearButton, "interstitialDidAppear called")
        adapterViewController?.setupAction(interstitialWillDisappearButton, "interstitialWillDisappear called")
        adapterViewController?.setupAction(interstitialDidDisappearButton, "interstitialDidDisappear called")
        adapterViewController?.setupAction(interstitialDidExpireButton, "interstitialDidExpire called")
        adapterViewController?.setupAction(interstitialDidReceiveTapEventButton, "interstitialDidReceiveTapEvent called")
    }
    
    @IBAction func showButtonClicked() {
        adapterViewController?.showButton.isEnabled = false
        interstitialController?.show(from: adapterViewController)
    }
}
