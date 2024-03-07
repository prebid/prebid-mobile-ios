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
import GoogleMobileAds

fileprivate let bannerConfigId = "prebid-ita-banner-300-250"
fileprivate let videoConfigId = "prebid-ita-video-outstream-original-api"
fileprivate let nativeConfigId = "prebid-ita-banner-native-styles"

class PrebidOriginalAPIMultiformatNativeStylesController:
    NSObject,
    AdaptedController,
    PrebidConfigurableBannerController,
    GADBannerViewDelegate {
    
    private lazy var configVC = PrebidMultiformatConfigurationController(controller: self)
    weak var rootController: AdapterViewController?
    var prebidConfigId = ""
    var adUnitID = ""
    
    var refreshInterval: TimeInterval = 0
    var adSize = CGSize.zero
    var gamSizes = [GADAdSize]()
    
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
    
    // Prebid
    private var adUnit: PrebidAdUnit!
    
    // GAM
    private var gamBanner: GAMBannerView?
    
    private let bannerViewDidReceiveAd = EventReportContainer()
    private let bannerViewDidFailToReceiveAd = EventReportContainer()
    private let bannerViewDidRecordImpression = EventReportContainer()
    private let bannerViewDidRecordClick = EventReportContainer()
    private let bannerViewWillPresentScreen = EventReportContainer()
    private let bannerViewWillDismissScreen = EventReportContainer()
    private let bannerViewDidDismissScreen = EventReportContainer()
    
    private let reloadButton = ThreadCheckingButton()
    private let stopRefreshButton = ThreadCheckingButton()
    
    private let configIdLabel = UILabel()
    
    required init(rootController: AdapterViewController) {
        super.init()
        
        self.rootController = rootController
        
        reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        stopRefreshButton.addTarget(self, action: #selector(stopRefresh), for: .touchUpInside)
        
        setupAdapterController()
    }
    
    func configurationController() -> BaseConfigurationController? {
        return configVC
    }
    
    func loadAd() {
        var bannerParameters: BannerParameters?
        var videoParameters: VideoParameters?
        var nativeParameters: NativeParameters?
        var configIds = [String]()
        
        if configVC.includeBanner {
            bannerParameters = BannerParameters()
            bannerParameters?.api = [Signals.Api.MRAID_2]
            bannerParameters?.adSizes = [adSize]
            configIds.append(bannerConfigId)
        }
        
        if configVC.includeVideo {
            videoParameters = VideoParameters(mimes: ["video/mp4"])
            videoParameters?.protocols = [Signals.Protocols.VAST_2_0]
            videoParameters?.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
            videoParameters?.placement = Signals.Placement.InBanner
            videoParameters?.adSize = adSize
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
        
        gamBanner = GAMBannerView(adSize: gamSizes.first ?? GADAdSizeFromCGSize(adSize))
        gamBanner?.validAdSizes = gamSizes.map(NSValueFromGADAdSize)
        gamBanner?.adUnitID = adUnitID
        gamBanner?.rootViewController = rootController
        gamBanner?.delegate = self
        
        let gamRequest = GAMRequest()
        adUnit.fetchDemand(adObject: gamRequest, request: prebidRequest) { [weak self] _ in
            self?.gamBanner?.load(gamRequest)
        }
    }
    
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
    
    private func setupAdapterController() {
        rootController?.showButton.isHidden = true
        configIdLabel.isHidden = true
        setupActions()
        
        rootController?.actionsView.addArrangedSubview(configIdLabel)
    }
    
    private func setupActions() {
        rootController?.setupAction(bannerViewDidReceiveAd, "bannerViewDidReceiveAd called", accessibilityLabel: "bannerViewDidReceiveAd called")
        rootController?.setupAction(bannerViewDidFailToReceiveAd, "bannerViewDidFailToReceiveAd called")
        rootController?.setupAction(bannerViewDidRecordImpression, "bannerViewDidRecordImpression called")
        rootController?.setupAction(bannerViewDidRecordClick, "bannerViewDidRecordClick called")
        rootController?.setupAction(bannerViewWillPresentScreen, "bannerViewWillPresentScreen called")
        rootController?.setupAction(bannerViewWillDismissScreen, "bannerViewWillDismissScreen called")
        rootController?.setupAction(bannerViewDidDismissScreen, "bannerViewDidDismissScreen called")
        
        rootController?.setupAction(reloadButton, "[Reload]")
        rootController?.setupAction(stopRefreshButton, "[Stop Refresh]")
        stopRefreshButton.isEnabled = true
    }
    
    private func resetEvents() {
        bannerViewDidReceiveAd.isEnabled = false
        bannerViewDidFailToReceiveAd.isEnabled = false
        bannerViewDidRecordImpression.isEnabled = false
        bannerViewDidRecordClick.isEnabled = false
        bannerViewWillPresentScreen.isEnabled = false
        bannerViewWillDismissScreen.isEnabled = false
        bannerViewDidDismissScreen.isEnabled = false
    }
    
    @objc private func reload() {
        gamBanner?.removeFromSuperview()
        gamBanner = nil
        reloadButton.isEnabled = false
        stopRefreshButton.isEnabled = true
        resetEvents()
        loadAd()
    }
    
    @objc private func stopRefresh() {
        stopRefreshButton.isEnabled = false
        adUnit.stopAutoRefresh()
    }
    
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        rootController?.bannerView.backgroundColor = .clear
        bannerViewDidReceiveAd.isEnabled = true
        reloadButton.isEnabled = true
        
        rootController?.bannerView.addSubview(bannerView)
        
        rootController?.bannerView.constraints.first { $0.firstAttribute == .width }?.constant = bannerView.adSize.size.width
        rootController?.bannerView.constraints.first { $0.firstAttribute == .height }?.constant = adSize.height
        
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { size in
            guard let bannerView = bannerView as? GAMBannerView else { return }
            bannerView.resize(GADAdSizeFromCGSize(size))
        }, failure: { (error) in
            Log.error("Error occuring during searching for Prebid creative size: \(error)")
        })
        
        rootController?.view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: rootController?.bannerView,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        resetEvents()
        bannerViewDidFailToReceiveAd.isEnabled = true
        Log.error(error.localizedDescription)
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        bannerViewDidRecordImpression.isEnabled = true
    }
    
    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        bannerViewDidRecordClick.isEnabled = true
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        bannerViewWillPresentScreen.isEnabled = true
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        bannerViewWillDismissScreen.isEnabled = true
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        bannerViewDidDismissScreen.isEnabled = true
    }
}
