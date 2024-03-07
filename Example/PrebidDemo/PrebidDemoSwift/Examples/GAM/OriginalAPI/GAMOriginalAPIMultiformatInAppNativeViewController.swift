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
fileprivate let gamRenderingMultiformatAdUnitId = "/21808260008/prebid-demo-multiformat"

class GAMOriginalAPIMultiformatInAppNativeViewController:
    MultiformatBaseViewController,
    GAMBannerAdLoaderDelegate,
    GADCustomNativeAdLoaderDelegate,
    NativeAdDelegate {
    
    // Prebid
    private var adUnit: PrebidAdUnit!
    private var configId = ""
    
    private var nativeAd: NativeAd!
    
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
    private var adLoader: GADAdLoader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAd()
        configIdLabel.text = "ConfigId: \(configId)"
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
        
        // 4. Make a bid request
        let gamRequest = GAMRequest()
        adUnit.fetchDemand(adObject: gamRequest, request: prebidRequest) { [weak self] _ in
            guard let self = self else { return }
            
            // 5. Configure and make a GAM ad request
            self.adLoader = GADAdLoader(adUnitID: gamRenderingMultiformatAdUnitId, rootViewController: self,
                                        adTypes: [GADAdLoaderAdType.customNative, GADAdLoaderAdType.gamBanner], options: [])
            self.adLoader.delegate = self
            self.adLoader.load(gamRequest)
        }
    }
    
    // MARK: - GAMBannerAdLoaderDelegate
    
    func validBannerSizes(for adLoader: GADAdLoader) -> [NSValue] {
        return [NSValueFromGADAdSize(GADAdSizeFromCGSize(adSize))]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        PrebidDemoLogger.shared.error("GAM did fail to receive ad with error: \(error)")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive bannerView: GAMBannerView) {
        self.bannerView.isHidden = false
        self.nativeView.isHidden = true
        self.bannerView.backgroundColor = .clear
        self.bannerView.addSubview(bannerView)
        
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { [weak self] size in
            bannerView.resize(GADAdSizeFromCGSize(size))
            
            self?.bannerView.constraints.first { $0.firstAttribute == .width }?.constant = size.width
            self?.bannerView.constraints.first { $0.firstAttribute == .height }?.constant = size.height
        }, failure: { (error) in
            PrebidDemoLogger.shared.error("Error occuring during searching for Prebid creative size: \(error)")
        })
    }
    
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        ["12304464"]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: customNativeAd)
    }
    
    // MARK: - NativeAdDelegate
    
    func nativeAdLoaded(ad: NativeAd) {
        nativeView.isHidden = false
        bannerView.isHidden = true
        
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
