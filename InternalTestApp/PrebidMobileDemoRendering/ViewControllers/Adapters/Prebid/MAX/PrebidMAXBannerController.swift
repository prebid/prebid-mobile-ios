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
import AppLovinSDK
import PrebidMobile
import PrebidMobileMAXAdapters

class PrebidMAXBannerController: NSObject, AdaptedController, PrebidConfigurableBannerController {
    
    private weak var rootController: AdapterViewController?
    
    var refreshInterval: TimeInterval = 0
    var adFormat: AdFormat?
    var additionalAdSizes = [CGSize]()
    
    var prebidConfigId = ""
    var maxAdUnitId = ""
    
    var isAdaptive = false
    
    var adUnitSize = CGSize()

    private var adBannerView: MAAdView?
    private var adUnit: MediationBannerAdUnit?
    private var mediationDelegate: MAXMediationBannerUtils?
    
    private let reloadButton = ThreadCheckingButton()
    private let stopRefreshButton = ThreadCheckingButton()
    private let configIdLabel = UILabel()
    
    private let fetchDemandFailedButton = EventReportContainer()
    
    private let didLoadAdButton = EventReportContainer()
    private let didFailToLoadAdButton = EventReportContainer()
    private let didFailToDisplayButton = EventReportContainer()
    private let didHideAdButton = EventReportContainer()
    private let didExpandAdButton = EventReportContainer()
    private let didCollapseAdButton = EventReportContainer()
    private let didClickAdButton = EventReportContainer()
    
    
    required init(rootController: AdapterViewController) {
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
        
        adBannerView = MAAdView(adUnitIdentifier: maxAdUnitId)
        adBannerView?.delegate = self
        adBannerView?.backgroundColor = .red
        adBannerView?.frame = CGRect(origin: .zero, size: adUnitSize)
        
        if isAdaptive {
            adBannerView?.setExtraParameterForKey("adaptive_banner", value: "true")
        }
        
        mediationDelegate = MAXMediationBannerUtils(adView: adBannerView!)
        
        adUnit = MediationBannerAdUnit(configID: prebidConfigId, size: adUnitSize, mediationDelegate: mediationDelegate!)
        
        if (refreshInterval > 0) {
            adUnit?.refreshInterval = refreshInterval
        }
        
        if additionalAdSizes.count > 0 {
            adUnit?.additionalSizes = additionalAdSizes
        }
        
        if let adFormat = adFormat {
            adUnit?.adFormat = adFormat
        }
        
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(key: dataPair.value, value: dataPair.key)
            }
        }
        
        // imp[].ext.keywords
        if !AppConfiguration.shared.adUnitContextKeywords.isEmpty {
            for keyword in AppConfiguration.shared.adUnitContextKeywords {
                adUnit?.addContextKeyword(keyword)
            }
        }
        
        // user.data
        if let userData = AppConfiguration.shared.userData {
            let ortbUserData = PBMORTBContentData()
            ortbUserData.ext = [:]
            
            for dataPair in userData {
                ortbUserData.ext?[dataPair.key] = dataPair.value
            }
            
            adUnit?.addUserData([ortbUserData])
        }
        
        // app.content.data
        if let appData = AppConfiguration.shared.appContentData {
            let ortbAppContentData = PBMORTBContentData()
            ortbAppContentData.ext = [:]
            
            for dataPair in appData {
                ortbAppContentData.ext?[dataPair.key] = dataPair.value
            }
            
            adUnit?.addAppContentData([ortbAppContentData])
        }
        
        adUnit?.fetchDemand { [weak self] result in
            guard let self = self,
                  let adBannerView = self.adBannerView,
                  let container = self.rootController?.bannerView else {
                return
            }
            
            if result != .prebidDemandFetchSuccess {
                self.fetchDemandFailedButton.isEnabled = true
                self.reloadButton.isEnabled = true
            }
            
            adBannerView.translatesAutoresizingMaskIntoConstraints = false
            let widthConstraint = NSLayoutConstraint(item: adBannerView,
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
            
            adBannerView.loadAd()
        }
        
        self.rootController?.bannerView.addSubview(self.adBannerView!)
    }
    
    // MARK: - Provate Methods
    
    private func setupAdapterController() {
        rootController?.showButton.isHidden = true
        
        setupActions()
        
        configIdLabel.isHidden = true
        rootController?.actionsView.addArrangedSubview(configIdLabel)
    }
    
    private func setupActions() {
        rootController?.setupAction(fetchDemandFailedButton, "fetchDemandFailed called")
        rootController?.setupAction(didLoadAdButton, "didLoadAd called")
        rootController?.setupAction(didFailToLoadAdButton, "didFailToLoadAd called")
        rootController?.setupAction(didFailToDisplayButton, "didFailToDisplay called")
        rootController?.setupAction(didHideAdButton, "didHideAd called")
        rootController?.setupAction(didExpandAdButton, "didExpandAd called")
        rootController?.setupAction(didCollapseAdButton, "didCollapseAd called")
        rootController?.setupAction(didClickAdButton, "didClickAd called")
        
        rootController?.setupAction(reloadButton, "[Reload]")
        
        rootController?.setupAction(stopRefreshButton, "[Stop Refresh]")
        stopRefreshButton.isEnabled = true
    }
    
    private func resetEvents() {
        fetchDemandFailedButton.isEnabled = false
        didLoadAdButton.isEnabled = false
        didFailToLoadAdButton.isEnabled = false
        didFailToDisplayButton.isEnabled = false
        didHideAdButton.isEnabled = false
        didExpandAdButton.isEnabled = false
        didCollapseAdButton.isEnabled = false
        didClickAdButton.isEnabled = false
    }
    
    @objc private func reload() {
        reloadButton.isEnabled = false
        stopRefreshButton.isEnabled = true
        
        resetEvents()
        
        adUnit?.fetchDemand { [weak self] result in
            
            if result != .prebidDemandFetchSuccess {
                self?.fetchDemandFailedButton.isEnabled = true
                self?.reloadButton.isEnabled = true
            }
            
            self?.adBannerView?.loadAd()
        }
    }
    
    @objc private func stopRefresh() {
        stopRefreshButton.isEnabled = false
        reloadButton.isEnabled = false
        adBannerView?.stopAutoRefresh()
        adUnit?.stopRefresh()
    }
}

// MARK: MAAdDelegate Protocol

extension PrebidMAXBannerController: MAAdViewAdDelegate {
    func didLoad(_ ad: MAAd) {
        resetEvents()
        didLoadAdButton.isEnabled = true
        reloadButton.isEnabled = true
        rootController?.bannerView.constraints.first { $0.firstAttribute == .width }?.constant = ad.size.width
        rootController?.bannerView.constraints.first { $0.firstAttribute == .height }?.constant = ad.size.height
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        Log.error(error.message)
        
        resetEvents()
        reloadButton.isEnabled = true
        didFailToLoadAdButton.isEnabled = true
        let nsError = NSError(domain: "MAX", code: error.code.rawValue, userInfo: [NSLocalizedDescriptionKey: error.message])
        adUnit?.adObjectDidFailToLoadAd(adObject: adBannerView!, with: nsError)
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        Log.error(error.message)
        
        resetEvents()
        reloadButton.isEnabled = true
        didFailToDisplayButton.isEnabled = true

        adUnit?.adObjectDidFailToLoadAd(adObject: adBannerView!, with: error as! Error)
    }
    
    func didDisplay(_ ad: MAAd) {
        // This method is deprecated for banner. It is used in full-screen ad only
    }
    
    func didHide(_ ad: MAAd) {
        didHideAdButton.isEnabled = true
    }
    
    func didExpand(_ ad: MAAd) {
        didExpandAdButton.isEnabled = true
    }
    
    func didCollapse(_ ad: MAAd) {
        didCollapseAdButton.isEnabled = true
    }
    
    func didClick(_ ad: MAAd) {
        didClickAdButton.isEnabled = true
    }
}
