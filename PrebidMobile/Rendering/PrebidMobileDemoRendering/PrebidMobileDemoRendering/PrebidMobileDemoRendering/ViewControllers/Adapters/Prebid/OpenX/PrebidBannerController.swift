//
//  PrebidBannerController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit

class PrebidBannerController: NSObject, AdaptedController, PrebidConfigurableBannerController, BannerViewDelegate {
    
    var refreshInterval: TimeInterval = 0
    
    var prebidConfigId = ""
    var adSizes = [CGSize]()
    var adFormat: PBMAdFormat?
    var nativeAdConfig: NativeAdConfiguration?
    
    var adBannerView : BannerView?
    
    weak var rootController: AdapterViewController?
    
    private let adViewDidReceiveAdButton = EventReportContainer()
    private let adViewDidFailToLoadAdButton = EventReportContainer()
    private let adViewWillPresentScreenButton = EventReportContainer()
    private let adViewDidDismissScreenButton = EventReportContainer()
    private let adViewWillLeaveApplicationButton = EventReportContainer()
    
    private let reloadButton = ThreadCheckingButton()
    private let stopRefreshButton = ThreadCheckingButton()
    
    let lastLoadedAdSizeLabel = UILabel()
    private let configIdLabel = UILabel()
    
    required init(rootController: AdapterViewController) {
        super.init()
        self.rootController = rootController
        
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
        
        let size = adSizes[0]
        adBannerView = BannerView(frame: CGRect(origin: .zero, size: size),
                                  configID: prebidConfigId,
                                  adSize: size)
        
        if (refreshInterval > 0) {
            adBannerView?.refreshInterval = refreshInterval
        }
        
        if adSizes.count > 1 {
            adBannerView?.additionalSizes = Array(adSizes.suffix(from: 1))
        }
        if let adFormat = adFormat {
            adBannerView?.adFormat = adFormat
            
            if adFormat == .video {
                adBannerView?.videoPlacementType = AppConfiguration.shared.videoPlacementType ?? .inBanner
            }
        }
        if let adPosition = AppConfiguration.shared.adPosition {
            adBannerView?.adPosition = adPosition
        }
        
        adBannerView?.nativeAdConfig = self.nativeAdConfig
        adBannerView?.delegate = self
        adBannerView?.accessibilityIdentifier = "PrebidBannerView"
        
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adBannerView?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        adBannerView?.loadAd()

        rootController?.bannerView.addSubview(self.adBannerView!)
        self.adBannerView!.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint  = NSLayoutConstraint(item: self.adBannerView!,
                                                  attribute: NSLayoutConstraint.Attribute.width,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: rootController?.bannerView,
                                                  attribute: NSLayoutConstraint.Attribute.width,
                                                  multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: self.adBannerView!,
                                                  attribute: NSLayoutConstraint.Attribute.height,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: rootController?.bannerView,
                                                  attribute: NSLayoutConstraint.Attribute.height,
                                                  multiplier: 1, constant: 0)
        rootController?.bannerView.addConstraints([widthConstraint, heightConstraint])
    }
    
    // MARK: - BannerViewDelegate
    
    func bannerViewPresentationController() -> UIViewController? {
        return rootController
    }
    
    func bannerView(_ bannerView: BannerView,
                    didReceiveAdWithAdSize adSize: CGSize) {
        resetEvents()
        reloadButton.isEnabled = true
        adViewDidReceiveAdButton.isEnabled = true
        rootController?.bannerView.constraints.first { $0.firstAttribute == .width }?.constant = adSize.width
        rootController?.bannerView.constraints.first { $0.firstAttribute == .height }?.constant = adSize.height
        lastLoadedAdSizeLabel.isHidden = false
        lastLoadedAdSizeLabel.text = "Ad Size: \(adSize.width)x\(adSize.height)"
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWith error: Error) {
        resetEvents()
        reloadButton.isEnabled = true
        adViewDidFailToLoadAdButton.isEnabled = true
    }

    func bannerViewWillPresentModal(_ bannerView: BannerView) {
        adViewWillPresentScreenButton.isEnabled = true
    }
    
    func bannerViewDidDismissModal(_ bannerView: BannerView) {
        adViewDidDismissScreenButton.isEnabled = true
    }
    
    func bannerViewWillLeaveApplication(_ bannerView: BannerView) {
        adViewWillLeaveApplicationButton.isEnabled = true
    }
    
    // MARK: - Private Methods
    
    private func setupAdapterController() {
        rootController?.showButton.isHidden = true
        
        setupActions()
        configIdLabel.isHidden = true
        rootController?.actionsView.addArrangedSubview(configIdLabel)
        lastLoadedAdSizeLabel.isHidden = true
        rootController?.actionsView.addArrangedSubview(lastLoadedAdSizeLabel)
    }
    
    private func setupActions() {
        rootController?.setupAction(adViewDidReceiveAdButton, "adViewDidReceiveAd called", accessibilityLabel: "adViewDidReceiveAd called")
        rootController?.setupAction(adViewDidFailToLoadAdButton, "adViewDidFailToLoadAd called")
        rootController?.setupAction(adViewWillPresentScreenButton, "adViewWillPresentScreen called")
        rootController?.setupAction(adViewDidDismissScreenButton, "adViewDidDismissScreen called")
        rootController?.setupAction(adViewWillLeaveApplicationButton, "adViewWillLeaveApplication called")
        
        rootController?.setupAction(reloadButton, "[Reload]")
        rootController?.setupAction(stopRefreshButton, "[Stop Refresh]")
        stopRefreshButton.isEnabled = true
    }
    
    private func resetEvents() {
        adViewDidReceiveAdButton.isEnabled = false
        adViewDidFailToLoadAdButton.isEnabled = false
        adViewWillPresentScreenButton.isEnabled = false
        adViewDidDismissScreenButton.isEnabled = false
        adViewWillLeaveApplicationButton.isEnabled = false
        
        lastLoadedAdSizeLabel.isHidden = true
    }
    
    @objc private func reload() {
        reloadButton.isEnabled = false
        stopRefreshButton.isEnabled = true
        
        resetEvents()
        
        adBannerView?.loadAd()
    }
    
    @objc private func stopRefresh() {
        stopRefreshButton.isEnabled = false
        adBannerView?.stopRefresh()
    }
}
