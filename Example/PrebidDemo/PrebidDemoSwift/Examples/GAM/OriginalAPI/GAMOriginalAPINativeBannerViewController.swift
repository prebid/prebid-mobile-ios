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

fileprivate let nativeStoredImpression = "prebid-demo-banner-native-styles"

class GAMOriginalAPINativeBannerViewController: BannerBaseViewController, GADBannerViewDelegate {
    
    // Prebid
    private var nativeUnit: NativeRequest!
    
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
    private var gamBannerView: GAMBannerView!
    private let gamRequest = GAMRequest()
    
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
        
        // 3. Create a GAMBannerView
        gamBannerView = GAMBannerView(adSize: GADAdSizeFluid)
        gamBannerView.adUnitID = "/21808260008/prebid-demo-original-native-styles"
        gamBannerView.rootViewController = self
        gamBannerView.delegate = self
        
        // Add GMA SDK banner view to the app UI
        bannerView.addSubview(gamBannerView)
        
        // 4. Make a bid request to Prebid Server
        nativeUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            PrebidDemoLogger.shared.info("Prebid demand fetch for GAM \(resultCode.name())")
            
            // 5. Load the native ad
            self?.gamBannerView.load(self?.gamRequest)
        }
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { size in
            guard let bannerView = bannerView as? GAMBannerView else { return }
            bannerView.resize(GADAdSizeFromCGSize(size))
        }, failure: { error in
            PrebidDemoLogger.shared.error("Error occuring during searching for Prebid creative size: \(error)")
        })
        
        bannerView.constraints.first { $0.firstAttribute == .width }?.constant = UIScreen.main.bounds.width * 0.1
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        PrebidDemoLogger.shared.error("GAM did fail to receive ad with error: \(error)")
    }
}
