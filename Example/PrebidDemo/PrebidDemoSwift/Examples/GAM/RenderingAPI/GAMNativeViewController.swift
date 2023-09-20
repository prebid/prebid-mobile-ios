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
import GoogleMobileAds
import PrebidMobile
import PrebidMobileGAMEventHandlers

fileprivate let nativeStoredImpression = "prebid-demo-banner-native-styles"
fileprivate let gamRenderingNativeAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"

class GAMNativeViewController: NativeBaseViewController, GADCustomNativeAdLoaderDelegate {
    
    // Prebid
    private var nativeUnit: NativeRequest!
    private weak var nativeAd: NativeAd?
    
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
    
    // GAM
    private var adLoader: GADAdLoader?
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    func createAd() {
        // 1. Create a NativeRequest
        nativeUnit = NativeRequest(configId: nativeStoredImpression, assets: nativeRequestAssets)
        
        // 2. Configure the NativeRequest
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        nativeUnit.eventtrackers = eventTrackers
        
        // 3. Make a bid request to Prebid Server
        nativeUnit.fetchDemand { result, kvResultDict in
            // 4. Prepare GAM request
            let gamRequest = GAMRequest()
            GAMUtils.shared.prepareRequest(gamRequest, bidTargeting: kvResultDict ?? [:])
            
            // 5. Load the native ad
            self.adLoader = GADAdLoader(adUnitID: gamRenderingNativeAdUnitId, rootViewController: self,
                                        adTypes: [.customNative], options: []) 
            self.adLoader?.delegate = self
            self.adLoader?.load(gamRequest)
        }
    }
    
    // MARK: - GADCustomNativeAdLoaderDelegate
    
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        return ["11934135"]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        let result = GAMUtils.shared.findCustomNativeAd(for: customNativeAd)
        
        switch result {
        case .success(let nativeAd):
            self.nativeAd = nativeAd
            titleLabel.text = nativeAd.title
            bodyLabel.text = nativeAd.text
            callToActionButton.setTitle(nativeAd.callToAction, for: .normal)
            sponsoredLabel.text = nativeAd.sponsoredBy
            
            if let iconString = nativeAd.iconUrl {
                ImageHelper.downloadImageAsync(iconString) { [weak self] result in
                    if case let .success(icon) = result {
                        DispatchQueue.main.async {
                            self?.iconView.image = icon
                        }
                    }
                }
            }
            
            if let imageString = nativeAd.imageUrl {
                ImageHelper.downloadImageAsync(imageString) { [weak self] result in
                    if case let .success(image) = result {
                        DispatchQueue.main.async {
                            self?.mainImageView.image = image
                        }
                    }
                }
            }
            
            self.nativeAd?.registerView(view: view, clickableViews: [callToActionButton])
        case .failure(let error):
            if error == GAMEventHandlerError.nonPrebidAd {
                titleLabel.text = customNativeAd.string(forKey: "title")
                bodyLabel.text = customNativeAd.string(forKey: "text")
                callToActionButton.setTitle(customNativeAd.string(forKey: "cta"), for: .normal)
                sponsoredLabel.text = customNativeAd.string(forKey: "sponsoredBy")
                
                if let imageString = customNativeAd.string(forKey: "imgUrl") {
                    ImageHelper.downloadImageAsync(imageString) { [weak self] result in
                        if case let .success(image) = result {
                            DispatchQueue.main.async {
                                self?.mainImageView.image = image
                            }
                        }
                    }
                }
                
                if let iconString = customNativeAd.string(forKey: "iconUrl") {
                    ImageHelper.downloadImageAsync(iconString) { [weak self] result in
                        if case let .success(icon) = result {
                            DispatchQueue.main.async {
                                self?.iconView.image = icon
                            }
                        }
                    }
                }
            }
        }
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        PrebidDemoLogger.shared.error("GAD ad loader did fail to receive ad with error: \(error.localizedDescription)")
    }
}
