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
import PrebidMobileGAMEventHandlers

class FeedGAMAdTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bannerView: UIView!
    
    var gamCustomTemplateIDs: [String] = []
    
    public var nativeAssets: [NativeAsset]?
    public var eventTrackers: [NativeEventTracker]?
    
    private var adUnit: NativeRequest?
    private var theNativeAd: PrebidMobile.NativeAd?
    
    private let nativeAdViewBox = NativeAdViewBox()
    
    private var adLoader: AdLoader?
    
    private var customTemplateAd: CustomNativeAd?
    
    private weak var rootController: UIViewController?
    
    func loadAd(
        configID: String,
        GAMAdUnitID: String,
        rootViewController: UIViewController,
        adTypes: [AdLoaderAdType]
    ) {
        setupNativeAdUnit(configId: configID)
        self.rootController = rootViewController
        
        adUnit?.fetchDemand { [weak self] bidInfo in
            guard let self = self else { return }
            
            guard bidInfo.resultCode == .prebidDemandFetchSuccess else {
                return
            }
            
            let dfpRequest = AdManagerRequest()
            GAMUtils.shared.prepareRequest(dfpRequest, bidTargeting: bidInfo.targetingKeywords ?? [:])
            
            self.adLoader = AdLoader(
                adUnitID: GAMAdUnitID,
                rootViewController: rootViewController,
                adTypes: adTypes,
                options: []
            )
            
            self.adLoader?.delegate = self
            self.adLoader?.load(dfpRequest)
        }
    }
    
    // MARK: - Helpers
    
    private func setupNativeAdUnit(configId: String) {
        adUnit = NativeRequest(configId: configId, assets: nativeAssets ?? [], eventTrackers: eventTrackers ?? [])
        adUnit?.context = ContextType.Social
        adUnit?.placementType = PlacementType.FeedContent
        adUnit?.contextSubType = ContextSubType.Social
    }
}

extension FeedGAMAdTableViewCell: CustomNativeAdLoaderDelegate {
    
    func customNativeAdFormatIDs(for adLoader: AdLoader) -> [String] {
        return gamCustomTemplateIDs
    }
    
    func adLoader(
        _ adLoader: AdLoader,
        didReceive nativeCustomTemplateAd: CustomNativeAd
    ) {
        customTemplateAd = nil
        
        let result = GAMUtils.shared.findCustomNativeAd(for: nativeCustomTemplateAd)
        switch result {
        case .success(let nativeAd):
            self.setupBanner()
            
            self.nativeAdViewBox.renderNativeAd(nativeAd)
            self.nativeAdViewBox.registerViews(nativeAd)
            self.theNativeAd = nativeAd // Note: RETAIN! or the tracking will not occur!
            self.customTemplateAd = nativeCustomTemplateAd
            nativeCustomTemplateAd.customClickHandler = { assetID in }
            nativeCustomTemplateAd.recordImpression()
        case .failure(let error):
            if error == GAMEventHandlerError.nonPrebidAd {
                self.nativeAdViewBox.renderCustomTemplateAd(nativeCustomTemplateAd)
                self.customTemplateAd = nativeCustomTemplateAd
                nativeCustomTemplateAd.recordImpression()
            }
        }
    }
    
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {}
    
    private func setupBanner() {
        guard let bannerView = self.bannerView else {
            return
        }
        
        nativeAdViewBox.embedIntoView(self.bannerView)
        let bannerConstraints = bannerView.constraints
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .width }!)
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .height }!)
        if let bannerParent = bannerView.superview {
            bannerParent.addConstraints(
                [
                    NSLayoutConstraint(
                        item: bannerView,
                        attribute: .width,
                        relatedBy: .lessThanOrEqual,
                        toItem: bannerParent,
                        attribute: .width,
                        multiplier: 1,
                        constant: -10
                    ),
                ]
            )
        }
    }
}
