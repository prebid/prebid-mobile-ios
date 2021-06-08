//
//  MoPubAdapterViewController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import UIKit
import MoPubSDK
import PrebidMobileRendering

class PrebidMoPubBannerController: NSObject, AdaptedController, PrebidConfigurableBannerController, MPAdViewDelegate {
    
    var refreshInterval: TimeInterval = 0
    
    var prebidConfigId = ""
    var moPubAdUnitId = ""
    var adUnitSize = CGSize()
    var additionalAdSizes = [CGSize]()
    var adFormat: AdFormat?
    var nativeAdConfig: NativeAdConfiguration?
    
    private var adBannerView : MPAdView?
    
    private weak var rootController: AdapterViewController?
    
    private let adViewDidLoadAdButton = EventReportContainer()
    private let adViewDidFailButton = EventReportContainer()
    private let willPresentModalViewButton = EventReportContainer()
    private let didDismissModalViewButton = EventReportContainer()
    private let willLeaveApplicationButton = EventReportContainer()
    private let viewControllerForPresentingModalViewButton = EventReportContainer()
    
    private let reloadButton = ThreadCheckingButton()
    private let stopRefreshButton = ThreadCheckingButton()
    private let configIdLabel = UILabel()
    
    private var adUnit: MoPubBannerAdUnit?
    
    // MARK: - AdaptedController
    
    required init(rootController:AdapterViewController) {
        self.rootController = rootController
        super.init()
        
        reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        stopRefreshButton.addTarget(self, action: #selector(stopRefresh), for: .touchUpInside)
        
        setupAdapterController()
    }
    
    func configurationController() -> BaseConfigurationController? {
        return PrebidBannerConfigurationController(controller: self)
    }
    
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        adBannerView = MPAdView(adUnitId: moPubAdUnitId)
        adBannerView?.delegate = self
        
        adUnit = MoPubBannerAdUnit(configID: prebidConfigId, size: adUnitSize)
        if (refreshInterval > 0) {
            adUnit?.refreshInterval = refreshInterval
        }
        if additionalAdSizes.count > 0 {
            adUnit?.additionalSizes = additionalAdSizes
        }
        if let adFormat = adFormat {
            adUnit?.adFormat = adFormat
        }
        adUnit?.nativeAdConfig = self.nativeAdConfig
        
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        adUnit?.fetchDemand(with: adBannerView!) { [weak self] result in
            guard let self = self,
                  let adBannerView = self.adBannerView,
                  let container = self.rootController?.bannerView
            else {
                return
            }
            adBannerView.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint  = NSLayoutConstraint(item: adBannerView,
                                                      attribute: .width,
                                                      relatedBy: .equal,
                                                      toItem: container,
                                                      attribute: .width,
                                                      multiplier: 1,
                                                      constant: 0)
            let heightConstraint = NSLayoutConstraint(item: adBannerView,
                                                      attribute: .height,
                                                      relatedBy: .equal,
                                                      toItem: container,
                                                      attribute: .height,
                                                      multiplier: 1,
                                                      constant: 0)
            container.addConstraints([widthConstraint, heightConstraint])
            container.layoutSubviews()
            
            adBannerView.loadAd(withMaxAdSize: kMPPresetMaxAdSize280Height)
        }
        
        rootController?.bannerView.addSubview(self.adBannerView!)
    }
    
    // MARK: - MPAdViewDelegate
    
    func viewControllerForPresentingModalView() -> UIViewController! {
        self.viewControllerForPresentingModalViewButton.isEnabled = true
        return rootController
    }
    
    func adViewDidLoadAd(_ view: MPAdView!, adSize:CGSize) {
        resetEvents()
        reloadButton.isEnabled = true
        self.adViewDidLoadAdButton.isEnabled = true
        rootController?.bannerView.constraints.first { $0.firstAttribute == .width }?.constant = adSize.width
        rootController?.bannerView.constraints.first { $0.firstAttribute == .height }?.constant = adSize.height
    }
    
    func adView(_ view: MPAdView!, didFailToLoadAdWithError error: Error!) {
        resetEvents()
        reloadButton.isEnabled = true
        self.adViewDidFailButton.isEnabled = true
        
        adUnit?.adObjectDidFailToLoadAd(adObject: view, with: error)
    }
    
    
    func willPresentModalView(forAd view: MPAdView!) {
        self.willPresentModalViewButton.isEnabled = true
    }
    
    func didDismissModalView(forAd view: MPAdView!) {
        self.didDismissModalViewButton.isEnabled = true
    }
    
    func willLeaveApplication(fromAd view: MPAdView!) {
        self.willLeaveApplicationButton.isEnabled = true;
    }
    
    // MARK: - Provate Methods
    
    private func setupAdapterController() {
        rootController?.showButton.isHidden = true
        
        setupActions()
        
        configIdLabel.isHidden = true
        rootController?.actionsView.addArrangedSubview(configIdLabel)
    }
    
    private func setupActions() {
        rootController?.setupAction(adViewDidLoadAdButton, "adViewDidLoadAd called")
        rootController?.setupAction(adViewDidFailButton, "adViewDidFail called")
        rootController?.setupAction(willPresentModalViewButton, "willPresentModalView called")
        rootController?.setupAction(didDismissModalViewButton, "didDismissModalView called")
        rootController?.setupAction(willLeaveApplicationButton, "willLeaveApplication called")
        rootController?.setupAction(viewControllerForPresentingModalViewButton, "viewControllerForPresentingModalView called")
        
        rootController?.setupAction(reloadButton, "[Reload]")
        
        rootController?.setupAction(stopRefreshButton, "[Stop Refresh]")
        stopRefreshButton.isEnabled = true
    }
    
    private func resetEvents() {
        adViewDidLoadAdButton.isEnabled = false
        adViewDidFailButton.isEnabled = false
        willPresentModalViewButton.isEnabled = false
        didDismissModalViewButton.isEnabled = false
        willLeaveApplicationButton.isEnabled = false
        viewControllerForPresentingModalViewButton.isEnabled = false
    }
    
    @objc private func reload() {
        reloadButton.isEnabled = false
        stopRefreshButton.isEnabled = true
        
        resetEvents()
        
        adUnit?.fetchDemand(with: adBannerView!) { [weak self] result in
            self?.adBannerView?.loadAd()
        }
    }
    
    @objc private func stopRefresh() {
        stopRefreshButton.isEnabled = false
        adUnit?.stopRefresh()
    }
}
