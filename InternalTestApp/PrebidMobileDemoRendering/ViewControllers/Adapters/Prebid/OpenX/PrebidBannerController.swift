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
import PrebidMobile

class PrebidBannerController: NSObject, AdaptedController, PrebidConfigurableBannerController, BannerViewDelegate {
    
    var refreshInterval: TimeInterval = 0
    
    var prebidConfigId = ""

    var adSizes = [CGSize]()
    var adFormat: AdFormat?
    
    var adBannerView: BannerView?
    
    var testPBSSDKConfig = false
    
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
    
    deinit {
        Targeting.shared.sourceapp = nil
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
            
            if adFormat == .video  {
                adBannerView?.videoParameters.placement = AppConfiguration.shared.videoPlacementType ?? .InBanner
            }
        }
        if let adPosition = AppConfiguration.shared.adPosition {
            adBannerView?.adPosition = adPosition
        }
    
        adBannerView?.delegate = self
        adBannerView?.accessibilityIdentifier = "PrebidBannerView"
        
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adBannerView?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        
        // imp[].ext.keywords
        if !AppConfiguration.shared.adUnitContextKeywords.isEmpty {
            for keyword in AppConfiguration.shared.adUnitContextKeywords {
                adBannerView?.addContextKeyword(keyword)
            }
        }
        
        // user.data
        if let userData = AppConfiguration.shared.userData {
            let ortbUserData = PBMORTBContentData()
            ortbUserData.ext = [:]
            
            for dataPair in userData {
                ortbUserData.ext?[dataPair.key] = dataPair.value
            }
            
            adBannerView?.addUserData([ortbUserData])
        }
        
        // app.content.data
        if let appData = AppConfiguration.shared.appContentData {
            let ortbAppContentData = PBMORTBContentData()
            ortbAppContentData.ext = [:]
            
            for dataPair in appData {
                ortbAppContentData.ext?[dataPair.key] = dataPair.value
            }
            
            adBannerView?.addAppContentData([ortbAppContentData])
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
        
        // Creative Factory Timeout Check
        
        if testPBSSDKConfig {
            let pbsSDKConfig = bannerView.lastBidResponse?.ext?.extPrebid?.passthrough?.filter({
                $0.type == "prebidmobilesdk"
            }).first?.sdkConfiguration
            
            if pbsSDKConfig?.cftBanner?.doubleValue != Prebid.shared.creativeFactoryTimeout || pbsSDKConfig?.cftPreRender?.doubleValue != Prebid.shared.creativeFactoryTimeoutPreRenderContent {
                resetEvents()
                adViewDidFailToLoadAdButton.isEnabled = true
            }
        }
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
