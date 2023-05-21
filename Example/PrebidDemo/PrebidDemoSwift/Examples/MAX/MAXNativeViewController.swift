/*   Copyright 2019-2022 Prebid.org, Inc.
 
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
import PrebidMobileMAXAdapters
import AppLovinSDK

fileprivate let nativeStoredImpression = "prebid-demo-banner-native-styles"
fileprivate let maxRenderingNativeAdUnitId = "e4375fdcc7c5e56c"

class MAXNativeViewController: BannerBaseViewController, MANativeAdDelegate {
    
    // Prebid
    private var maxMediationNativeAdUnit: MediationNativeAdUnit!
    private var maxMediationDelegate: MAXMediationNativeUtils!
    
    private var nativeRequestAssets: [NativeAsset] {
        let image = NativeAssetImage(minimumWidth: 200, minimumHeight: 50, required: true)
        image.type = ImageAsset.Main
        
        let icon = NativeAssetImage(minimumWidth: 20, minimumHeight: 20, required: true)
        icon.type = ImageAsset.Icon
        
        let title = NativeAssetTitle(length: 90, required: true)
        let body = NativeAssetData(type: DataAsset.description, required: true)
        let cta = NativeAssetData(type: DataAsset.ctatext, required: true)
        let sponsored = NativeAssetData(type: DataAsset.sponsored, required: true)
        
        return [title, icon, image, sponsored, body, cta]
    }
    
    private var eventTrackers: [NativeEventTracker] {
        [NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image,EventTracking.js])]
    }
    
    // MAX
    private var maxNativeAdLoader: MANativeAdLoader!
    private weak var maxLoadedNativeAd: MAAd!
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    deinit {
        if let maxLoadedNativeAd = maxLoadedNativeAd {
            maxNativeAdLoader?.destroy(maxLoadedNativeAd)
        }
    }
    
    func createAd() {
        // 1. Create a MANativeAdLoader
        maxNativeAdLoader = MANativeAdLoader(adUnitIdentifier: maxRenderingNativeAdUnitId)
        maxNativeAdLoader.nativeAdDelegate = self
        
        // 2. Create the MAXMediationNativeUtils
        maxMediationDelegate = MAXMediationNativeUtils(nativeAdLoader: maxNativeAdLoader)
        
        // 3. Create the MediationNativeAdUnit
        maxMediationNativeAdUnit = MediationNativeAdUnit(configId: nativeStoredImpression, mediationDelegate: maxMediationDelegate)
        
        // 4. Configure the MediationNativeAdUnit
        maxMediationNativeAdUnit.addNativeAssets(nativeRequestAssets)
        maxMediationNativeAdUnit.setContextType(.Social)
        maxMediationNativeAdUnit.setPlacementType(.FeedContent)
        maxMediationNativeAdUnit.setContextSubType(.Social)
        maxMediationNativeAdUnit.addEventTracker(eventTrackers)
        
        // 5. Create a MAXNativeAdView
        let nativeAdViewNib = UINib(nibName: "MAXNativeAdView", bundle: Bundle.main)
        let maNativeAdView = nativeAdViewNib.instantiate(withOwner: nil, options: nil).first! as! MANativeAdView?
        
        // 6. Create a MANativeAdViewBinder
        let adViewBinder = MANativeAdViewBinder.init(builderBlock: { (builder) in
            builder.iconImageViewTag = 1
            builder.titleLabelTag = 2
            builder.bodyLabelTag = 3
            builder.advertiserLabelTag = 4
            builder.callToActionButtonTag = 5
            builder.mediaContentViewTag = 123
        })
        
        // 7. Bind views
        maNativeAdView!.bindViews(with: adViewBinder)
        
        // 7. Make a bid request to Prebid Server
        maxMediationNativeAdUnit.fetchDemand { [weak self] result in
            // 8. Load the native ad
            self?.maxNativeAdLoader.loadAd(into: maNativeAdView!)
        }
    }
    
    // MARK: - MANativeAdDelegate
    
    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        if let nativeAd = maxLoadedNativeAd {
            maxNativeAdLoader?.destroy(nativeAd)
        }
        
        maxLoadedNativeAd = ad
        
        bannerView.backgroundColor = .clear
        nativeAdView?.translatesAutoresizingMaskIntoConstraints = false
        bannerView.addSubview(nativeAdView!)
        
        bannerView.heightAnchor.constraint(equalTo: nativeAdView!.heightAnchor).isActive = true
        bannerView.topAnchor.constraint(equalTo: nativeAdView!.topAnchor).isActive = true
        bannerView.leftAnchor.constraint(equalTo: nativeAdView!.leftAnchor).isActive = true
        bannerView.rightAnchor.constraint(equalTo: nativeAdView!.rightAnchor).isActive = true
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        PrebidDemoLogger.shared.error("\(error.message)")
    }
    
    func didClickNativeAd(_ ad: MAAd) {}
}
