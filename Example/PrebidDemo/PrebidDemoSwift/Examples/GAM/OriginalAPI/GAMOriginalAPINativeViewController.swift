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
import GoogleMobileAds

fileprivate let storedPrebidImpression = "prebid-demo-banner-native-styles"
fileprivate let gamRenderingNativeAdUnitId = "/21808260008/apollo_custom_template_native_ad_unit"

class GAMOriginalAPINativeViewController:
    NativeBaseViewController,
    GADAdLoaderDelegate,
    GADCustomNativeAdLoaderDelegate,
    NativeAdDelegate {
    
    // Prebid
    private var nativeUnit: NativeRequest!
    private var nativeAd: NativeAd!
    
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
    private let gamRequest = GAMRequest()
    private var adLoader: GADAdLoader!
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    func createAd() {
        // 1. Setup a NativeRequest
        nativeUnit = NativeRequest(configId: storedPrebidImpression, assets: nativeRequestAssets)
        
        // 2. Configure the NativeRequest
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        nativeUnit.eventtrackers = eventTrackers
        
        // 3. Make a bid request
        nativeUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            guard let self = self else { return }
            
            //4. Configure and make a GAM ad request
            self.adLoader = GADAdLoader(adUnitID: gamRenderingNativeAdUnitId,rootViewController: self,
                                        adTypes: [GADAdLoaderAdType.customNative], options: [])
            self.adLoader.delegate = self
            self.adLoader.load(self.gamRequest)
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
        PrebidDemoLogger.shared.error("GAM did fail to receive ad with error: \(error)")
    }
    
    // MARK: - NativeAdDelegate
    
    func nativeAdLoaded(ad: NativeAd) {
        nativeAd = ad
        titleLabel.text = ad.title
        bodyLabel.text = ad.text
        
        if let iconString = ad.iconUrl {
            ImageHelper.downloadImageAsync(iconString) { result in
                if case let .success(icon) = result {
                    DispatchQueue.main.async {
                        self.iconView.image = icon
                    }
                }
            }
        }
        
        if let imageString = ad.imageUrl {
            ImageHelper.downloadImageAsync(imageString) { result in
                if case let .success(image) = result {
                    DispatchQueue.main.async {
                        self.mainImageView.image = image
                    }
                }
            }
        }
        
        callToActionButton.setTitle(ad.callToAction, for: .normal)
        sponsoredLabel.text = ad.sponsoredBy
        
        nativeAd.registerView(view: view, clickableViews: [callToActionButton])
    }
    
    func nativeAdNotFound() {
        PrebidDemoLogger.shared.error("Native ad not found")
    }
    
    func nativeAdNotValid() {
        PrebidDemoLogger.shared.error("Native ad not valid")
    }
}
