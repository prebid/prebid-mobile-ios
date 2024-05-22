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
import GoogleInteractiveMediaAds

class PrebidOriginalAPIVideoInstreamViewController:
    NSObject,
    AdaptedController,
    IMAAdsLoaderDelegate,
    IMAAdsManagerDelegate {
    
    private weak var rootController: AdapterViewController!
    
    var videoContentURL = ""
    var prebidConfigId = ""
    var gamAdUnitVideo = ""
    
    // Prebid
    private var adUnit: VideoAdUnit!
    
    // IMA
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager?
    var contentPlayhead: IMAAVPlayerContentPlayhead?
    
    var contentPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    private let adsLoaderAdLoadedButton = EventReportContainer()
    private let adsLoaderFailedButton = EventReportContainer()
    private let adsManagerDidReceivedEventLoadedButton = EventReportContainer()
    private let adsManagerDidReceivedErrorButton = EventReportContainer()
    private let adsManagerDidRequestContentPauseButton = EventReportContainer()
    private let adsManagerDidRequestContentResumeButton = EventReportContainer()
    private let contentDidFinishPlayingButton = EventReportContainer()
    
    private let configIdLabel = UILabel()
    
    required init(rootController: AdapterViewController) {
        super.init()
        self.rootController = rootController
        rootController.showButton.isHidden = true
        
        setupAdapterController()
    }
    
    deinit {
        adsManager?.destroy()
        contentPlayer?.pause()
        contentPlayer = nil
    }
    
    func loadAd() {
        
        configIdLabel.isHidden = false
        configIdLabel.text = "Config ID: \(prebidConfigId)"
        
        rootController.bannerView.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 250))
        rootController.bannerView.constraints.first { $0.firstAttribute == .width }?.constant = 300
        rootController.bannerView.constraints.first { $0.firstAttribute == .height }?.constant = 250
        
        rootController.bannerView.backgroundColor = .clear
        
        // Setup content player
        guard let contentURL = URL(string: videoContentURL) else {
            Log.error("Please, use a valid URL for the content URL.")
            return
        }
        
        contentPlayer = AVPlayer(url: contentURL)
        
        // Create a player layer for the player.
        playerLayer = AVPlayerLayer(player: contentPlayer)
        
        // Size, position, and display the AVPlayer.
        playerLayer?.frame = rootController.bannerView.layer.bounds
        rootController.bannerView.layer.addSublayer(playerLayer!)
        
        // Set up our content playhead and contentComplete callback.
        if let contentPlayer = contentPlayer {
            contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: contentPlayer)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: contentPlayer?.currentItem)
        
        adUnit = VideoAdUnit(configId: prebidConfigId, size: CGSize(width: 640, height: 480))
        
        // imp[].ext.data
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(key: dataPair.key, value: dataPair.value)
            }
        }
        
        // imp[].ext.keywords
        if !AppConfiguration.shared.adUnitContextKeywords.isEmpty {
            for keyword in AppConfiguration.shared.adUnitContextKeywords {
                adUnit?.addContextKeyword(keyword)
            }
        }
        
        // user.data
        if let userData = AppConfiguration.shared.userData {
            let ortbUserData = PBMORTBContentData()
            ortbUserData.ext = [:]
            
            for dataPair in userData {
                ortbUserData.ext?[dataPair.key] = dataPair.value
            }
            
            adUnit?.addUserData([ortbUserData])
        }
        
        // app.content.data
        if let appData = AppConfiguration.shared.appContentData {
            let ortbAppContentData = PBMORTBContentData()
            ortbAppContentData.ext = [:]
            
            for dataPair in appData {
                ortbAppContentData.ext?[dataPair.key] = dataPair.value
            }
            
            adUnit?.addAppContentData([ortbAppContentData])
        }
        
        let parameters = VideoParameters(mimes: ["video/mp4"]) 
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOn]
        parameters.protocols = [Signals.Protocols.VAST_2_0,Signals.Protocols.VAST_3_0,Signals.Protocols.VAST_4_0]
        parameters.api = [1,2]            // or alternative enum values [Api.VPAID_1, Api.VPAID_2]
        parameters.maxBitrate = 1500
        parameters.minBitrate = 300
        parameters.maxDuration = 30
        parameters.minDuration = 5
        adUnit.parameters = parameters
        
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = self
        
        adUnit.fetchDemand { [weak self] (resultCode, prebidKeys: [String: String]?) in
            guard let self = self else { return }
            if resultCode == .prebidDemandFetchSuccess {
                do {
                    let adServerTag = try IMAUtils.shared.generateInstreamUriForGAM(adUnitID: self.gamAdUnitVideo, adSlotSizes: [.Size640x480], customKeywords: prebidKeys!)
                    
                    let adDisplayContainer = IMAAdDisplayContainer(adContainer: self.rootController.bannerView, viewController: self.rootController)
                    let request = IMAAdsRequest(adTagUrl: adServerTag, adDisplayContainer: adDisplayContainer, contentPlayhead: nil, userContext: nil)
                    self.adsLoader.requestAds(with: request)
                } catch {
                    Log.error("\(error.localizedDescription)")
                    self.contentPlayer?.play()
                }
            } else {
                Log.error("Error constructing IMA Tag")
                self.contentPlayer?.play()
            }
        }
    }
    
    private func setupAdapterController() {
        rootController?.showButton.isHidden = true
        configIdLabel.isHidden = true
        setupActions(rootController: rootController)
        
        rootController?.actionsView.addArrangedSubview(configIdLabel)
    }
    
    private func setupActions(rootController: AdapterViewController) {
        rootController.setupAction(adsLoaderAdLoadedButton, "adsLoaderAdLoaded called")
        rootController.setupAction(adsLoaderFailedButton, "adsLoaderFailed called")
        rootController.setupAction(adsManagerDidReceivedEventLoadedButton, "adsManagerDidReceivedEventLoaded called")
        rootController.setupAction(adsManagerDidReceivedErrorButton, "adsManagerDidReceivedError called")
        rootController.setupAction(adsManagerDidRequestContentResumeButton, "adsManagerDidRequestContentResume called")
        rootController.setupAction(contentDidFinishPlayingButton, "contentDidFinishPlaying called")
    }
    
    @objc func contentDidFinishPlaying(_ notification: Notification) {
        // Make sure we don't call contentComplete as a result of an ad completing.
        if (notification.object as! AVPlayerItem) == contentPlayer?.currentItem {
            contentDidFinishPlayingButton.isEnabled = true
            adsLoader.contentComplete()
        }
    }
    
    // MARK: - IMAAdsLoaderDelegate
    
    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
        adsLoaderAdLoadedButton.isEnabled = true
        adsManager = adsLoadedData.adsManager
        adsManager?.delegate = self
        
        // Initialize the ads manager.
        adsManager?.initialize(with: nil)
    }
    
    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        Log.error("IMA did fail with error: \(String(describing: adErrorData.adError.message))")
        adsLoaderFailedButton.isEnabled = true
        contentPlayer?.play()
    }
    
    // MARK: - IMAAdsManagerDelegate
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        if event.type == IMAAdEventType.LOADED {
            // When the SDK notifies us that ads have been loaded, play them.
            adsManagerDidReceivedEventLoadedButton.isEnabled = true
            adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        Log.error("AdsManager error: \(error.message ?? "nil")")
        adsManagerDidReceivedErrorButton.isEnabled = true
        contentPlayer?.play()
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        // The SDK is going to play ads, so pause the content.
        adsManagerDidRequestContentPauseButton.isEnabled = true
        contentPlayer?.pause()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        // The SDK is done playing ads (at least for now), so resume the content.
        adsManagerDidRequestContentResumeButton.isEnabled = true
        contentPlayer?.play()
    }
}
