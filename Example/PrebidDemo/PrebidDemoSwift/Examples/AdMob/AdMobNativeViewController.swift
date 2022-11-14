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
import PrebidMobileAdMobAdapters

fileprivate let nativeStoredImpression = "imp-prebid-banner-native-styles"
fileprivate let nativeStoredResponse = "response-prebid-banner-native-styles"
fileprivate let admobRenderingNativeAdUnitId = "ca-app-pub-5922967660082475/8634069303"

class AdMobNativeViewController: NativeBaseViewController, GADNativeAdLoaderDelegate {

    // Prebid
    private var nativeUnit: NativeRequest!
    private var nativeAd: NativeAd?
    private var mediationDelegate: AdMobMediationNativeUtils!
    private var admobMediationNativeAdUnit: MediationNativeAdUnit!
    
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
    
    // AdMob
    private var gadRequest: GADRequest!
    private var adLoader: GADAdLoader?
    
    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = nativeStoredResponse
        createAd()
    }
    
    func createAd() {
        gadRequest = GADRequest()
        mediationDelegate = AdMobMediationNativeUtils(gadRequest: gadRequest)
        admobMediationNativeAdUnit = MediationNativeAdUnit(configId: nativeStoredImpression, mediationDelegate: mediationDelegate)
        admobMediationNativeAdUnit.addNativeAssets(nativeRequestAssets)
        admobMediationNativeAdUnit.setContextType(.Social)
        admobMediationNativeAdUnit.setPlacementType(.FeedContent)
        admobMediationNativeAdUnit.setContextSubType(.Social)
        
        admobMediationNativeAdUnit.addEventTracker(eventTrackers)
        
        admobMediationNativeAdUnit.fetchDemand { [weak self] result in
            guard let self = self else { return }
            
            self.adLoader = GADAdLoader(adUnitID: admobRenderingNativeAdUnitId, rootViewController: self,
                                        adTypes: [ .native ], options: nil)
            self.adLoader?.delegate = self
            
            self.adLoader?.load(self.gadRequest)
        }
    }
    
    // MARK: - GADNativeAdLoaderDelegate
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        titleLabel.text = nativeAd.headline
        bodyLabel.text = nativeAd.body
        callToActionButton.setTitle(nativeAd.callToAction, for: .normal)
        sponsoredLabel.text = nativeAd.advertiser
        
        if let icon = nativeAd.icon {
            iconView.image = icon.image
        }
        
        // FIXME: Fatal error: NSArray element failed to match the Swift Array Element type. Expected GADNativeAdImage but found GADNativeAdImage.
//        if let image = nativeAd.images?.first {
//            mainImageView.image = image.image
//        }
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        PrebidDemoLogger.shared.error("GAD ad loader did fail to receive ad with error: \(error.localizedDescription)")
    }
}
