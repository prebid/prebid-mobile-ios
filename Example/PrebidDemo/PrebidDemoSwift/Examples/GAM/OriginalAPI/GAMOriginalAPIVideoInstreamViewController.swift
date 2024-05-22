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

fileprivate let videoContentURL = "https://storage.googleapis.com/gvabox/media/samples/stock.mp4"
fileprivate let storedImpVideo = "prebid-demo-video-interstitial-320-480-original-api"
fileprivate let gamAdUnitVideo = "/21808260008/prebid_demo_app_instream"

class GAMOriginalAPIVideoInstreamViewController:
    InstreamBaseViewController,
    IMAAdsLoaderDelegate,
    IMAAdsManagerDelegate {
    
    // Prebid
    private var adUnit: InstreamVideoAdUnit!
    
    // IMA
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager?
    var contentPlayhead: IMAAVPlayerContentPlayhead?
    
    var contentPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instreamView.backgroundColor = .clear
        playButton.layer.zPosition = CGFloat.greatestFiniteMagnitude
        
        // Setup content player
        guard let contentURL = URL(string: videoContentURL) else {
            PrebidDemoLogger.shared.error("Please, use a valid URL for the content URL.")
            return
        }
        
        contentPlayer = AVPlayer(url: contentURL)
        
        // Create a player layer for the player.
        playerLayer = AVPlayerLayer(player: contentPlayer)
        
        // Size, position, and display the AVPlayer.
        playerLayer?.frame = instreamView.layer.bounds
        instreamView.layer.addSublayer(playerLayer!)
        
        // Set up our content playhead and contentComplete callback.
        if let contentPlayer = contentPlayer {
            contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: contentPlayer)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: contentPlayer?.currentItem)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerLayer?.frame = instreamView.layer.bounds
        adsManager?.destroy()
        contentPlayer?.pause()
        contentPlayer = nil
    }
    
    override func onPlayButtonPressed(_ sender: AnyObject) {
        super.onPlayButtonPressed(sender)
        
        playButton.isHidden = true
        
        // Setup and load in-stream video
        createAd()
    }
    
    func createAd() {
        // 1. Create InstreamVideoAdUnit
        adUnit = InstreamVideoAdUnit(configId: storedImpVideo, size: CGSize(width: 640, height: 480))
        
        // 2. Configure Video Parameters
        let parameters = VideoParameters(mimes: ["video/mp4"])
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOn]
        adUnit.videoParameters = parameters
        
        // 3. Prepare IMAAdsLoader
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = self
        
        // 4. Make a bid request
        adUnit.fetchDemand { [weak self] (resultCode, prebidKeys: [String: String]?) in
            guard let self = self else { return }
            if resultCode == .prebidDemandFetchSuccess {
                do {
                    
                    // 5. Generate GAM Instream URI
                    let adServerTag = try IMAUtils.shared.generateInstreamUriForGAM(adUnitID: gamAdUnitVideo, adSlotSizes: [.Size640x480], customKeywords: prebidKeys!)
                    
                    // 6. Load IMA ad request
                    let adDisplayContainer = IMAAdDisplayContainer(adContainer: self.instreamView, viewController: self)
                    let request = IMAAdsRequest(adTagUrl: adServerTag, adDisplayContainer: adDisplayContainer, contentPlayhead: nil, userContext: nil)
                    self.adsLoader.requestAds(with: request)
                } catch {
                    PrebidDemoLogger.shared.error("\(error.localizedDescription)")
                    self.contentPlayer?.play()
                }
            } else {
                PrebidDemoLogger.shared.error("Error constructing IMA Tag")
                self.contentPlayer?.play()
            }
        }
    }
    
    @objc func contentDidFinishPlaying(_ notification: Notification) {
        // Make sure we don't call contentComplete as a result of an ad completing.
        if (notification.object as! AVPlayerItem) == contentPlayer?.currentItem {
            adsLoader.contentComplete()
        }
    }
    
    // MARK: - IMAAdsLoaderDelegate
    
    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
        adsManager = adsLoadedData.adsManager
        adsManager?.delegate = self
        
        // Initialize the ads manager.
        adsManager?.initialize(with: nil)
    }
    
    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        PrebidDemoLogger.shared.error("IMA did fail with error: \(adErrorData.adError)")
        contentPlayer?.play()
    }
    
    // MARK: - IMAAdsManagerDelegate
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        if event.type == IMAAdEventType.LOADED {
            // When the SDK notifies us that ads have been loaded, play them.
            adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        PrebidDemoLogger.shared.error("AdsManager error: \(error.message ?? "nil")")
        contentPlayer?.play()
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        // The SDK is going to play ads, so pause the content.
        contentPlayer?.pause()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        // The SDK is done playing ads (at least for now), so resume the content.
        contentPlayer?.play()
    }
}
