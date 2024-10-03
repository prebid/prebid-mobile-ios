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
import AppLovinSDK
import PrebidMobileMAXAdapters

class PrebidMAXNativeController: NSObject, AdaptedController {
    
    public var maxAdUnitId = ""
    public var prebidConfigId = ""
    
    public var nativeAssets: [NativeAsset]?
    public var eventTrackers: [NativeEventTracker]?
    
    private var nativeAdUnit: MediationNativeAdUnit!
    private var mediationDelegate: MAXMediationNativeUtils!
    
    private var nativeAdLoader: MANativeAdLoader?
    private var loadedNativeAd: MAAd?
    
    private weak var rootController: AdapterViewController?
    
    private let fetchDemandFailedButton = EventReportContainer()
    private let didLoadNativeAdButton = EventReportContainer()
    private let didFailToLoadNativeAdButton = EventReportContainer()
    private let didClickNativeAdButton = EventReportContainer()
    
    required init(rootController: AdapterViewController) {
        super.init()
        self.rootController = rootController
        
        setupActions(rootController: rootController)
    }
    
    func loadAd() {
        setUpBannerArea(rootController: rootController!)
        
        nativeAdLoader = MANativeAdLoader(adUnitIdentifier: maxAdUnitId)
        nativeAdLoader?.nativeAdDelegate = self
        mediationDelegate = MAXMediationNativeUtils(nativeAdLoader: nativeAdLoader!)
        nativeAdUnit = MediationNativeAdUnit(configId: prebidConfigId, mediationDelegate: mediationDelegate)
        
        nativeAdUnit.setContextType(ContextType.Social)
        nativeAdUnit.setPlacementType(PlacementType.FeedContent)
        nativeAdUnit.setContextSubType(ContextSubType.Social)
        
        if let nativeAssets = nativeAssets {
            nativeAdUnit.addNativeAssets(nativeAssets)
        }
        if let eventTrackers = eventTrackers {
            nativeAdUnit.addEventTracker(eventTrackers)
        }
        
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                nativeAdUnit?.addContextData(key: dataPair.value, value: dataPair.key)
            }
        }
        
        // imp[].ext.keywords
        if !AppConfiguration.shared.adUnitContextKeywords.isEmpty {
            for keyword in AppConfiguration.shared.adUnitContextKeywords {
                nativeAdUnit?.addContextKeyword(keyword)
            }
        }
        
        // user.data
        if let userData = AppConfiguration.shared.userData {
            let ortbUserData = PBMORTBContentData()
            ortbUserData.ext = [:]
            
            for dataPair in userData {
                ortbUserData.ext?[dataPair.key] = dataPair.value
            }
            
            nativeAdUnit?.addUserData([ortbUserData])
        }
        
        // app.content.data
        if let appData = AppConfiguration.shared.appContentData {
            let ortbAppContentData = PBMORTBContentData()
            ortbAppContentData.ext = [:]
            
            for dataPair in appData {
                ortbAppContentData.ext?[dataPair.key] = dataPair.value
            }
            
            nativeAdUnit?.addAppContentData([ortbAppContentData])
        }
        
        nativeAdUnit.fetchDemand { [weak self] result in
            guard let self = self else { return }
            
            if result != .prebidDemandFetchSuccess {
                self.fetchDemandFailedButton.isEnabled = true
            }
            
            self.nativeAdLoader?.loadAd(into: self.createNativeAdView())
        }
    }
    
    private func setUpBannerArea(rootController: AdapterViewController) {
        guard let bannerView = rootController.bannerView else {
            return
        }

        let bannerConstraints = bannerView.constraints
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .width }!)
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .height }!)
        if let bannerParent = bannerView.superview {
            let bannerHeightConstraint = bannerView.heightAnchor.constraint(equalToConstant: 200)
            bannerHeightConstraint.priority = .defaultLow
            let bannerWidthConstraint = NSLayoutConstraint(item: bannerView,
                                                           attribute: .width,
                                                           relatedBy: .lessThanOrEqual,
                                                           toItem: bannerParent,
                                                           attribute: .width,
                                                           multiplier: 1,
                                                           constant: -10)
            NSLayoutConstraint.activate([bannerWidthConstraint, bannerHeightConstraint])
        }
    }
    
    private func createNativeAdView() -> MANativeAdView {
        let nativeAdViewNib = UINib(nibName: "MAXNativeAdView", bundle: Bundle.main)
        let nativeAdView = nativeAdViewNib.instantiate(withOwner: nil, options: nil).first! as! MANativeAdView?
        
        let adViewBinder = MANativeAdViewBinder.init(builderBlock: { (builder) in
            builder.iconImageViewTag = 1
            builder.titleLabelTag = 2
            builder.bodyLabelTag = 3
            builder.advertiserLabelTag = 4
            builder.callToActionButtonTag = 5
            builder.mediaContentViewTag = 123
        })
        
        nativeAdView!.bindViews(with: adViewBinder)
        return nativeAdView!
    }
    
    private func setupActions(rootController: AdapterViewController) {
        rootController.setupAction(fetchDemandFailedButton, "fetchDemandFailed called")
        rootController.setupAction(didLoadNativeAdButton, "didLoadNativeAd called")
        rootController.setupAction(didFailToLoadNativeAdButton, "didFailToLoadNativeAd called")
        rootController.setupAction(didClickNativeAdButton, "didClickNativeAd called")
    }
}

extension PrebidMAXNativeController: MANativeAdDelegate {
    
    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        didLoadNativeAdButton.isEnabled = true
        
        if let nativeAd = loadedNativeAd {
            nativeAdLoader?.destroy(nativeAd)
        }
        
        guard let bannerView = rootController?.bannerView else {
            return
        }

        rootController?.showButton.isHidden = true
        bannerView.backgroundColor = .clear
        
        loadedNativeAd = ad
        nativeAdView?.translatesAutoresizingMaskIntoConstraints = false
        bannerView.addSubview(nativeAdView!)
        
        bannerView.heightAnchor.constraint(equalTo: nativeAdView!.heightAnchor).isActive = true
        bannerView.topAnchor.constraint(equalTo: nativeAdView!.topAnchor).isActive = true
        bannerView.leftAnchor.constraint(equalTo: nativeAdView!.leftAnchor).isActive = true
        bannerView.rightAnchor.constraint(equalTo: nativeAdView!.rightAnchor).isActive = true
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        didFailToLoadNativeAdButton.isEnabled = true
    }
    
    func didClickNativeAd(_ ad: MAAd) {
        didClickNativeAdButton.isEnabled = true
    }
}

