/*   Copyright 2018-2023 Prebid.org, Inc.
 
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

fileprivate let bannerConfigId = "prebid-ita-banner-300-250"
fileprivate let videoConfigId = "prebid-ita-video-outstream-original-api"
fileprivate let nativeConfigId = "prebid-ita-banner-native-styles"

class PrebidOriginalAPIMultiformatInAppNativeController:
    NSObject,
    AdaptedController,
    PrebidConfigurableBannerController,
    GAMBannerAdLoaderDelegate,
    GADCustomNativeAdLoaderDelegate,
    NativeAdDelegate,
    NativeAdEventDelegate {
    
    var refreshInterval: TimeInterval = 30000
    var prebidConfigId = ""
    var adUnitID = ""
    var bannerAdSize = CGSize.zero
    
    private lazy var configVC = PrebidMultiformatConfigurationController(controller: self)
    weak var rootController: AdapterViewController?
    private var nativeAdViewBox: NativeAdViewBoxProtocol?
    
    private let bannerViewDidReceiveAd = EventReportContainer()
    
    private let adLoaderDidReceiveCustomNativeAd = EventReportContainer()
    private let adLoaderDidFailToReceiveAd = EventReportContainer()
    
    private let configIdLabel = UILabel()
    private let reloadButton = ThreadCheckingButton()
    private let stopRefreshButton = ThreadCheckingButton()
    
    // Prebid
    private var adUnit: PrebidAdUnit!
    private var nativeAd: NativeAd?
    
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
    private var gamBanner: GAMBannerView?
    
    func configurationController() -> BaseConfigurationController? {
        return configVC
    }
    
    required init(rootController: AdapterViewController) {
        super.init()
        
        self.rootController = rootController
        setupAdapterController()
    }
    
    func loadAd() {
        var bannerParameters: BannerParameters?
        var videoParameters: VideoParameters?
        var nativeParameters: NativeParameters?
        var configIds = [String]()
        
        if configVC.includeBanner {
            bannerParameters = BannerParameters()
            bannerParameters?.api = [Signals.Api.MRAID_2]
            bannerParameters?.adSizes = [bannerAdSize]
            configIds.append(bannerConfigId)
        }
        
        if configVC.includeVideo {
            videoParameters = VideoParameters(mimes: ["video/mp4"])
            videoParameters?.protocols = [Signals.Protocols.VAST_2_0]
            videoParameters?.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
            videoParameters?.placement = Signals.Placement.InBanner
            videoParameters?.adSize = bannerAdSize
            configIds.append(videoConfigId)
        }
        
        if configVC.includeNative {
            nativeParameters = NativeParameters()
            nativeParameters?.assets = nativeAssets
            nativeParameters?.context = ContextType.Social
            nativeParameters?.placementType = PlacementType.FeedContent
            nativeParameters?.contextSubType = ContextSubType.Social
            nativeParameters?.eventtrackers = eventTrackers
            configIds.append(nativeConfigId)
        }
        
        prebidConfigId = configIds.randomElement() ?? bannerConfigId
        
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        adUnit = PrebidAdUnit(configId: prebidConfigId)
        adUnit.setAutoRefreshMillis(time: refreshInterval)
        
        let prebidRequest = PrebidRequest(bannerParameters: bannerParameters, videoParameters: videoParameters, nativeParameters: nativeParameters)
        addData(to: prebidRequest)
        
        let gamRequest = GAMRequest()
        adUnit.fetchDemand(adObject: gamRequest, request: prebidRequest) { [weak self] _ in
            guard let self = self else { return }
            
            // 5. Configure and make a GAM ad request
            self.adLoader = GADAdLoader(adUnitID: self.adUnitID, rootViewController: self.rootController,
                                        adTypes: [GADAdLoaderAdType.customNative, GADAdLoaderAdType.gamBanner], options: [])
            self.adLoader.delegate = self
            self.adLoader.load(gamRequest)
        }
    }
    
    // MARK: - GAMBannerAdLoaderDelegate
    
    func validBannerSizes(for adLoader: GADAdLoader) -> [NSValue] {
        return [NSValueFromGADAdSize(GADAdSizeFromCGSize(bannerAdSize))]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        resetEvents()
        reloadButton.isEnabled = true
        adLoaderDidFailToReceiveAd.isEnabled = true
        Log.error("GAM did fail to receive ad with error: \(error)")
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive bannerView: GAMBannerView) {
        bannerViewDidReceiveAd.isEnabled = true
        reloadButton.isEnabled = true
        
        nativeAdViewBox?.removeFromSuperview()
        gamBanner?.removeFromSuperview()
        
        gamBanner = bannerView
        
        rootController?.bannerView.addSubview(bannerView)
        bannerView.centerXAnchor.constraint(equalTo: rootController!.bannerView.centerXAnchor).isActive = true
        
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { size in
            bannerView.resize(GADAdSizeFromCGSize(size))
        }, failure: { (error) in
            Log.error("Error occuring during searching for Prebid creative size: \(error)")
        })
        
        rootController?.bannerView.constraints.first { $0.firstAttribute == .width }?.constant = bannerView.adSize.size.width
        rootController?.bannerView.constraints.first { $0.firstAttribute == .height }?.constant = bannerView.adSize.size.height
    }
    
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        ["12304464"]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        reloadButton.isEnabled = true
        adLoaderDidReceiveCustomNativeAd.isEnabled = true
        
        nativeAdViewBox?.removeFromSuperview()
        gamBanner?.removeFromSuperview()
        
        setupNativeAdView(NativeAdViewBox())
        
        Utils.shared.delegate = self
        Utils.shared.findNative(adObject: customNativeAd)
    }
    
    // MARK: - NativeAdDelegate
    
    func nativeAdLoaded(ad: NativeAd) {
        nativeAd = ad
        nativeAd?.delegate = self
        nativeAdViewBox?.renderNativeAd(ad)
        nativeAdViewBox?.registerViews(ad)
    }
    
    func nativeAdNotFound() {
        Log.error("Native ad not found")
    }
    
    func nativeAdNotValid() {
        Log.error("Native ad not valid")
    }
    
    // MARK: - Private zone
    
    private func addData(to prebidRequest: PrebidRequest) {
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                prebidRequest.addExtData(key: dataPair.key, value: dataPair.value)
            }
        }
        
        // imp[].ext.keywords
        if !AppConfiguration.shared.adUnitContextKeywords.isEmpty {
            for keyword in AppConfiguration.shared.adUnitContextKeywords {
                prebidRequest.addExtKeyword(keyword)
            }
        }
        
        // user.data
        if let userData = AppConfiguration.shared.userData {
            let ortbUserData = PBMORTBContentData()
            ortbUserData.ext = [:]
            
            for dataPair in userData {
                ortbUserData.ext?[dataPair.key] = dataPair.value
            }
            
            prebidRequest.addUserData([ortbUserData])
        }
        
        // app.content.data
        if let appData = AppConfiguration.shared.appContentData {
            let ortbAppContentData = PBMORTBContentData()
            ortbAppContentData.ext = [:]
            
            for dataPair in appData {
                ortbAppContentData.ext?[dataPair.key] = dataPair.value
            }
            
            prebidRequest.addAppContentData([ortbAppContentData])
        }
    }
    
    private func setupNativeAdView(_ nativeAdViewBox: NativeAdViewBoxProtocol) {
        self.nativeAdViewBox = nativeAdViewBox
        fillBannerArea(rootController: rootController!)
        self.nativeAdViewBox?.setUpDummyValues()
    }
    
    private func setupActions() {
        rootController?.setupAction(bannerViewDidReceiveAd, "bannerViewDidReceiveAd called")
        rootController?.setupAction(adLoaderDidReceiveCustomNativeAd, "adLoaderDidReceiveCustomNativeAd called")
        rootController?.setupAction(adLoaderDidFailToReceiveAd, "adLoaderDidFailToReceiveAd called")
        
        rootController?.setupAction(reloadButton, "[Reload]")
        rootController?.setupAction(stopRefreshButton, "[Stop Refresh]")
        stopRefreshButton.isEnabled = true
    }
    
    private func resetEvents() {
        bannerViewDidReceiveAd.isEnabled = false
        adLoaderDidReceiveCustomNativeAd.isEnabled = false
        adLoaderDidFailToReceiveAd.isEnabled = false
    }
    
    private func setupAdapterController() {
        rootController?.showButton.isHidden = true
        configIdLabel.isHidden = true
        setupActions()
        
        reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        stopRefreshButton.addTarget(self, action: #selector(stopRefresh), for: .touchUpInside)
        
        rootController?.actionsView.addArrangedSubview(configIdLabel)
    }
    
    private func fillBannerArea(rootController: AdapterViewController) {
        guard let bannerView = rootController.bannerView else {
            return
        }
        
        nativeAdViewBox?.embedIntoView(bannerView)
        
        if let screenBounds = rootController.view.window?.screen.bounds {
            bannerView.constraints.first { $0.firstAttribute == .width }?.constant = screenBounds.width * 0.9
            bannerView.constraints.first { $0.firstAttribute == .height }?.constant = screenBounds.height / 4
        }
    }
    
    @objc private func reload() {
        reloadButton.isEnabled = false
        stopRefreshButton.isEnabled = true
        
        resetEvents()
        loadAd()
    }
    
    @objc private func stopRefresh() {
        stopRefreshButton.isEnabled = false
        adUnit.stopAutoRefresh()
    }
}
