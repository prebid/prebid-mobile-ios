/*   Copyright 2019-2023 Prebid.org, Inc.
 
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

fileprivate let storedPrebidImpressions = ["prebid-demo-banner-300-250", "prebid-demo-video-outstream-original-api", "prebid-demo-banner-native-styles"]
fileprivate let gamRenderingMultiformatAdUnitId = "/21808260008/prebid-demo-multiformat-native-styles"

class GAMOriginalAPIMultiformatNativeStylesViewController: BannerBaseViewController, GADBannerViewDelegate {
    
    // Prebid
    private var adUnit: PrebidAdUnit!
    private var configId = ""
    
    private var nativeAssets: [NativeAsset] {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAd()
    }
    
    func createAd() {
        // 1. Setup a PrebidAdUnit
        configId = storedPrebidImpressions.randomElement()!
        adUnit = PrebidAdUnit(configId: configId)
        adUnit.setAutoRefreshMillis(time: 30_000)
        
        // 2. Setup the parameters
        let bannerParameters = BannerParameters()
        bannerParameters.api = [Signals.Api.MRAID_2]
        bannerParameters.adSizes = [adSize]
        
        let videoParameters = VideoParameters(mimes: ["video/mp4"])
        videoParameters.protocols = [Signals.Protocols.VAST_2_0]
        videoParameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        videoParameters.placement = Signals.Placement.InBanner
        videoParameters.adSize = adSize
        
        let nativeParameters = NativeParameters()
        nativeParameters.assets = nativeAssets
        nativeParameters.context = ContextType.Social
        nativeParameters.placementType = PlacementType.FeedContent
        nativeParameters.contextSubType = ContextSubType.Social
        nativeParameters.eventtrackers = eventTrackers
        
        // 3. Configure the PrebidRequest
        let prebidRequest = PrebidRequest(bannerParameters: bannerParameters, videoParameters: videoParameters, nativeParameters: nativeParameters)
        
        // 4. Create a GAMBannerView
        gamBannerView = GAMBannerView(adSize: GADAdSizeFluid)
        gamBannerView.validAdSizes = [NSValueFromGADAdSize(GADAdSizeFluid), NSValueFromGADAdSize(GADAdSizeBanner), NSValueFromGADAdSize(GADAdSizeMediumRectangle)]
        gamBannerView.adUnitID = gamRenderingMultiformatAdUnitId
        gamBannerView.rootViewController = self
        gamBannerView.delegate = self
        
        // Add GMA SDK banner view to the app UI
        bannerView.addSubview(gamBannerView)
        
        // 5. Make a bid request
        let gamRequest = GAMRequest()
        adUnit.fetchDemand(adObject: gamRequest, request: prebidRequest) { [weak self] _ in
            guard let self = self else { return }
            
            // 6. Load the native ad
            self.gamBannerView.load(gamRequest)
        }
    }
    
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.bannerView.backgroundColor = .clear
        
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { size in
            guard let bannerView = bannerView as? GAMBannerView else { return }
            bannerView.resize(GADAdSizeFromCGSize(size))
        }, failure: { error in
            PrebidDemoLogger.shared.error("Error occuring during searching for Prebid creative size: \(error)")
        })
        
        let centerConstraint = NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal,
                                                  toItem: self.bannerView, attribute: .centerX, multiplier: 1, constant: 0)
                               
        view.addConstraint(centerConstraint)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        PrebidDemoLogger.shared.error("GAM did fail to receive ad with error: \(error)")
    }
}
