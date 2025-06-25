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
import GoogleMobileAds
import PrebidMobile
import PrebidMobileAdMobAdapters
import Alamofire

enum GADAdSizeType {
    case regular
    case adaptiveAnchored
}

class PrebidAdMobBannerViewController:
    NSObject,
    AdaptedController,
    PrebidConfigurableBannerController,
    GoogleMobileAds.BannerViewDelegate {
    
    var refreshInterval: TimeInterval = 0
    
    var prebidConfigId = ""
    
    var adMobAdUnitId = ""
    var adUnitSize = CGSize()
    var additionalAdSizes = [CGSize]()
    var adFormat: PrebidMobile.AdFormat?
    
    var request = Request()
    
    var gadAdSizeType: GADAdSizeType
    
    private var adBannerView : GoogleMobileAds.BannerView?
    
    private var prebidBanner: DisplayView?
    
    private weak var rootController: AdapterViewController?
    
    private let adViewDidLoadAdButton = EventReportContainer()
    private let adViewDidFailButton = EventReportContainer()
    private let willPresentScreenButton = EventReportContainer()
    private let willDismissScreenButton = EventReportContainer()
    private let didDismissScreenButton = EventReportContainer()
    private let didRecordImpressionButton = EventReportContainer()
    
    private let reloadButton = ThreadCheckingButton()
    private let stopRefreshButton = ThreadCheckingButton()
    private let configIdLabel = UILabel()
    
    private var adUnit: MediationBannerAdUnit?
    
    private var mediationDelegate: AdMobMediationBannerUtils?
    
    // MARK: - AdaptedController
    
    required init(rootController:AdapterViewController) {
        self.rootController = rootController
        gadAdSizeType = .regular
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
        
        adBannerView = GoogleMobileAds.BannerView()
        adBannerView?.adUnitID = adMobAdUnitId
        adBannerView?.rootViewController = rootController
        adBannerView?.delegate = self
        
        mediationDelegate = AdMobMediationBannerUtils(gadRequest: request, bannerView: adBannerView!)
        
        adUnit = MediationBannerAdUnit(
            configID: prebidConfigId,
            size: adUnitSize,
            mediationDelegate: mediationDelegate!
        )
        
        if (refreshInterval > 0) {
            adUnit?.refreshInterval = refreshInterval
        }
        
        if additionalAdSizes.count > 0 {
            adUnit?.additionalSizes = additionalAdSizes
        }
        
        if let adFormat = adFormat {
            adUnit?.adFormat = adFormat
        }
        
        adUnit?.fetchDemand { [weak self] result in
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
            
            let sizeWithMaxWidth = self.additionalAdSizes.max {
                $0.width < $1.width
            }
            
            switch self.gadAdSizeType {
            case .regular:
                adBannerView.adSize = adSizeFor(cgSize: self.adUnitSize)
            case .adaptiveAnchored:
                adBannerView.adSize = currentOrientationAnchoredAdaptiveBanner(
                    width: sizeWithMaxWidth?.width ?? self.adUnitSize.width
                )
            }
            
            adBannerView.load(self.request)
        }
        
        rootController?.bannerView.addSubview(self.adBannerView!)
    }
    
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GoogleMobileAds.BannerView) {
        resetEvents()
        reloadButton.isEnabled = true
        self.adViewDidLoadAdButton.isEnabled = true
        rootController?.bannerView.constraints.first { $0.firstAttribute == .width }?.constant = bannerView.adSize.size.width
        rootController?.bannerView.constraints.first { $0.firstAttribute == .height }?.constant = bannerView.adSize.size.height
    }
    
    func bannerView(_ bannerView: GoogleMobileAds.BannerView, didFailToReceiveAdWithError error: Error) {
        print("didFailToReceiveAdWithError \(error.localizedDescription)")
        
        resetEvents()
        reloadButton.isEnabled = true
        self.adViewDidFailButton.isEnabled = true
        
        adUnit?.adObjectDidFailToLoadAd(adObject: adBannerView!, with: error)
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GoogleMobileAds.BannerView) {
        self.didRecordImpressionButton.isEnabled = true
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GoogleMobileAds.BannerView) {
        self.willPresentScreenButton.isEnabled = true
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GoogleMobileAds.BannerView) {
        self.willDismissScreenButton.isEnabled = true
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GoogleMobileAds.BannerView) {
        self.didDismissScreenButton.isEnabled = true
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
        rootController?.setupAction(didRecordImpressionButton, "didRecordImpression called")
        rootController?.setupAction(willPresentScreenButton, "willPresentScreen called")
        rootController?.setupAction(willDismissScreenButton, "willDismissScreen called")
        rootController?.setupAction(didDismissScreenButton, "didDismissScreen called")
        
        rootController?.setupAction(reloadButton, "[Reload]")
        
        rootController?.setupAction(stopRefreshButton, "[Stop Refresh]")
        stopRefreshButton.isEnabled = true
    }
    
    private func resetEvents() {
        adViewDidLoadAdButton.isEnabled = false
        adViewDidFailButton.isEnabled = false
        willPresentScreenButton.isEnabled = false
        willDismissScreenButton.isEnabled = false
        didDismissScreenButton.isEnabled = false
        didRecordImpressionButton.isEnabled = false
    }
    
    @objc private func reload() {
        reloadButton.isEnabled = false
        stopRefreshButton.isEnabled = true
        
        resetEvents()
        
        adUnit?.fetchDemand { [weak self] result in
            self?.adBannerView?.load(self?.request)
        }
    }
    
    @objc private func stopRefresh() {
        stopRefreshButton.isEnabled = false
        adUnit?.stopRefresh()
    }
}
