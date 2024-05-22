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

class PrebidNativeAdController: NSObject, AdaptedController {
    
    public var prebidConfigId = ""

    public var nativeAssets: [NativeAsset]?
    public var eventTrackers: [NativeEventTracker]?
    
    private weak var rootController: AdapterViewController?
    
    private var nativeAdViewBox: NativeAdViewBoxProtocol?
    
    private var adUnit: NativeRequest?
    private var theNativeAd: NativeAd?
    
    private let fetchDemandSuccessButton = EventReportContainer()
    private let fetchDemandFailedButton = EventReportContainer()
    private let getNativeAdSuccessButton = EventReportContainer()
    private let getNativeAdFailedButton = EventReportContainer()
    private let adDidExpireButton = EventReportContainer()
    private let adDidLogImpressionButton = EventReportContainer()
    private let adWasClickedButton = EventReportContainer()
    
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
        rootController.setupAction(fetchDemandSuccessButton, "fetchDemand success")
        rootController.setupAction(fetchDemandFailedButton, "fetchDemand failed")
        rootController.setupAction(getNativeAdSuccessButton, "getNativeAd success")
        rootController.setupAction(getNativeAdFailedButton, "getNativeAd failed")
        rootController.setupAction(adDidExpireButton, "adDidExpire called")
        rootController.setupAction(adDidLogImpressionButton, "adDidLogImpression called")
        rootController.setupAction(adWasClickedButton, "adWasClicked called")
    }
    
    func loadAd() {
        setupNativeAdUnit(configId: prebidConfigId)

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
        
        adUnit?.fetchDemand(completion: { [weak self] result, kvResultDict in
            guard let self = self else {
                return
            }
            
            guard result == .prebidDemandFetchSuccess else {
                self.fetchDemandFailedButton.isEnabled = true
                return
            }
            
            self.fetchDemandSuccessButton.isEnabled = true
            
            guard let kvResultDict = kvResultDict, let cacheId = kvResultDict[PrebidLocalCacheIdKey] else {
                self.getNativeAdFailedButton.isEnabled = true
                return
            }
            
            guard let nativeAd = NativeAd.create(cacheId: cacheId) else {
                self.getNativeAdFailedButton.isEnabled = true
                return
            }
            
            self.getNativeAdSuccessButton.isEnabled = true
            
            self.nativeAdViewBox?.renderNativeAd(nativeAd)
            self.nativeAdViewBox?.registerViews(nativeAd)
            self.theNativeAd = nativeAd // Note: RETAIN! or the tracking will not occur!
            self.theNativeAd?.delegate = self
        })
    }
    
    // MARK: - Helpers
    
    private func setupNativeAdUnit(configId: String) {
        adUnit = NativeRequest(configId: configId, assets: nativeAssets ?? [], eventTrackers: eventTrackers ?? [])
        adUnit?.context = ContextType.Social
        adUnit?.placementType = PlacementType.FeedContent
        adUnit?.contextSubType = ContextSubType.Social
    }
}

extension PrebidNativeAdController: NativeAdEventDelegate {
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
