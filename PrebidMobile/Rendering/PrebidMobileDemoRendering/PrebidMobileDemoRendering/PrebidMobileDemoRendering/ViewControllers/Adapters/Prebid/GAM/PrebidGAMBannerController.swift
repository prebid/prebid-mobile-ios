//
//  PrebidGAMBannerController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import GoogleMobileAds
import PrebidMobileGAMEventHandlers

class PrebidGAMBannerController: NSObject, AdaptedController, PrebidConfigurableBannerController, PBMBannerViewDelegate {
    
    var refreshInterval: TimeInterval = 0
    
    var prebidConfigId = ""
    var gamAdUnitId = ""
    var validAdSizes = [GADAdSize]()
    var adFormat: PBMAdFormat?
    var nativeAdConfig: NativeAdConfiguration?
    
    var adBannerView : PBMBannerView?
    
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
        
        let adEventHandler = GAMBannerEventHandler(adUnitID: gamAdUnitId, validGADAdSizes: validAdSizes.map(NSValueFromGADAdSize))
        adBannerView = PBMBannerView(configId: prebidConfigId, eventHandler: adEventHandler)
       
        if (refreshInterval > 0) {
            adBannerView?.refreshInterval = refreshInterval
        }
        
        if let adFormat = adFormat {
            adBannerView?.adFormat = adFormat
            
            if adFormat == .video {
                adBannerView?.videoPlacementType = AppConfiguration.shared.videoPlacementType ?? .inBanner
            }
        }
        adBannerView?.nativeAdConfig = self.nativeAdConfig
       
        adBannerView?.delegate = self
        adBannerView?.accessibilityIdentifier = "PBMBannerView"
        
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
    
    // MARK: - PBMBannerViewDelegate
    
    func bannerViewPresentationController() -> UIViewController? {
        return rootController
    }
    
    func bannerViewDidReceiveAd(_ bannerView: PBMBannerView, adSize: CGSize) {
        resetEvents()
        reloadButton.isEnabled = true
        adViewDidReceiveAdButton.isEnabled = true
        
        func setBannerSize(_ bannerSize: CGSize) {
            if let constraints = rootController?.bannerView.constraints {
                constraints.first { $0.firstAttribute == .width }?.constant = bannerSize.width
                constraints.first { $0.firstAttribute == .height }?.constant = bannerSize.height
            }
            lastLoadedAdSizeLabel.isHidden = false
            lastLoadedAdSizeLabel.text = "Ad Size: \(bannerSize.width)x\(bannerSize.height)"
        }
        
        if nativeAdConfig == nil {
            setBannerSize(adSize)
        } else {
            // FIXME: (PB-X) Read from bid???
            setBannerSize(CGSize(width: 300, height: 250))
        }
    }
    
    func bannerView(_ bannerView: PBMBannerView, didFailToReceiveAdWithError error: Error?) {
        resetEvents()
        reloadButton.isEnabled = true
        adViewDidFailToLoadAdButton.isEnabled = true
    }
    
    func bannerViewWillPresentModal(_ bannerView: PBMBannerView) {
        adViewWillPresentScreenButton.isEnabled = true
    }
    
    func bannerViewDidDismissModal(_ bannerView: PBMBannerView) {
        adViewDidDismissScreenButton.isEnabled = true
    }
    
    func bannerViewWillLeaveApplication(_ bannerView: PBMBannerView) {
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
        rootController?.setupAction(adViewDidReceiveAdButton, "adViewDidReceiveAd called")
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
