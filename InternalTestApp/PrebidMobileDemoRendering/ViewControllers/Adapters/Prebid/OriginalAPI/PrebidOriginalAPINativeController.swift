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
import GoogleMobileAds

class PrebidOriginalAPINativeController: NSObject, AdaptedController, GADAdLoaderDelegate, GADCustomNativeAdLoaderDelegate {
    
    var prebidConfigId = ""
    var adUnitID = ""

    public var nativeAssets: [NativeAsset]?
    public var eventTrackers: [NativeEventTracker]?
    
    private weak var rootController: AdapterViewController?
    
    private var nativeAdViewBox: NativeAdViewBoxProtocol?
    
    private var nativeUnit: NativeRequest!
    private var nativeAd: NativeAd?
    
    private var adLoader: GADAdLoader!
    
    private let nativeAdLoadedButton = EventReportContainer()
    private let nativeAdNotFoundButton = EventReportContainer()
    private let nativeAdNotValidButton = EventReportContainer()
    private let adDidExpireButton = EventReportContainer()
    private let adDidLogImpressionButton = EventReportContainer()
    private let adWasClickedButton = EventReportContainer()
    
    private let configIdLabel = UILabel()
    
    required init(rootController: AdapterViewController) {
        super.init()
        self.rootController = rootController
        rootController.showButton.isHidden = true
    }
    
    deinit {
        Prebid.shared.shouldAssignNativeAssetID = false
    }
    
    func setupNativeAdView(_ nativeAdViewBox: NativeAdViewBoxProtocol) {
        
        self.nativeAdViewBox = nativeAdViewBox
        
        fillBannerArea(rootController: self.rootController!)
        setupActions(rootController: self.rootController!)
        
        configIdLabel.isHidden = true
        
        self.nativeAdViewBox?.setUpDummyValues()
    }
    
    private func fillBannerArea(rootController: AdapterViewController) {
        guard let bannerView = rootController.bannerView else {
            return
        }
        
        nativeAdViewBox?.embedIntoView(bannerView)
        let bannerConstraints = bannerView.constraints
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .width }!)
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .height }!)
        if let bannerParent = bannerView.superview {
            bannerParent.addConstraints([
                NSLayoutConstraint(item: bannerView,
                                   attribute: .width,
                                   relatedBy: .lessThanOrEqual,
                                   toItem: bannerParent,
                                   attribute: .width,
                                   multiplier: 1,
                                   constant: -10),
            ])
        }
    }
    
    private func showDummyValues() {
        nativeAdViewBox?.setUpDummyValues()
    }
    
    private func setupActions(rootController: AdapterViewController) {
        rootController.setupAction(nativeAdLoadedButton, "nativeAdLoaded called")
        rootController.setupAction(nativeAdNotFoundButton, "nativeAdNotFound called")
        rootController.setupAction(nativeAdNotValidButton, "nativeAdNotValid called")
        rootController.setupAction(adDidExpireButton, "adDidExpire called")
        rootController.setupAction(adDidLogImpressionButton, "adDidLogImpression called")
        rootController.setupAction(adWasClickedButton, "adWasClicked called")
    }
    
    func loadAd() {
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
                
        nativeUnit = NativeRequest(configId: prebidConfigId, assets: nativeAssets)
        
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        nativeUnit.eventtrackers = eventTrackers
        
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                nativeUnit?.addContextData(key: dataPair.key, value: dataPair.value)
            }
        }
        
        // imp[].ext.keywords
        if !AppConfiguration.shared.adUnitContextKeywords.isEmpty {
            for keyword in AppConfiguration.shared.adUnitContextKeywords {
                nativeUnit?.addContextKeyword(keyword)
            }
        }
        
        // user.data
        if let userData = AppConfiguration.shared.userData {
            let ortbUserData = PBMORTBContentData()
            ortbUserData.ext = [:]
            
            for dataPair in userData {
                ortbUserData.ext?[dataPair.key] = dataPair.value
            }
            
            nativeUnit?.addUserData([ortbUserData])
        }
        
        // app.content.data
        if let appData = AppConfiguration.shared.appContentData {
            let ortbAppContentData = PBMORTBContentData()
            ortbAppContentData.ext = [:]
            
            for dataPair in appData {
                ortbAppContentData.ext?[dataPair.key] = dataPair.value
            }
            
            nativeUnit?.addAppContentData([ortbAppContentData])
        }
        
        let gamRequest = GAMRequest()
        nativeUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            guard let self = self else { return }
            
            self.adLoader = GADAdLoader(adUnitID: self.adUnitID, rootViewController: self.rootController,
                                        adTypes: [GADAdLoaderAdType.customNative], options: [])
            self.adLoader.delegate = self
            self.adLoader.load(gamRequest)
        }
    }
    
    // MARK: GADCustomNativeAdLoaderDelegate
    
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        ["11934135"]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: customNativeAd)
    }
    
    // MARK: GADAdLoaderDelegate
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        Log.error("GAM did fail to receive ad with error: \(error)")
    }
}

extension PrebidOriginalAPINativeController: NativeAdDelegate, NativeAdEventDelegate {
    
    func nativeAdLoaded(ad: NativeAd) {
        DispatchQueue.main.async {
            self.nativeAdLoadedButton.isEnabled = true
        }
        self.nativeAd = ad
        self.nativeAd?.delegate = self
        self.nativeAdViewBox?.renderNativeAd(ad)
        self.nativeAdViewBox?.registerViews(ad)
    }
    
    func nativeAdNotFound() {
        DispatchQueue.main.async {
            self.nativeAdNotFoundButton.isEnabled = true
        }
    }
    
    func nativeAdNotValid() {
        DispatchQueue.main.async {
            self.nativeAdNotValidButton.isEnabled = true
        }
    }
    
    func adDidExpire(ad: NativeAd) {
        DispatchQueue.main.async {
            self.adDidExpireButton.isEnabled = true
        }
    }
    
    func adDidLogImpression(ad: NativeAd) {
        DispatchQueue.main.async {
            self.adDidLogImpressionButton.isEnabled = true
        }
    }
    
    func adWasClicked(ad: NativeAd) {
        DispatchQueue.main.async {
            self.adWasClickedButton.isEnabled = true
        }
    }
}
