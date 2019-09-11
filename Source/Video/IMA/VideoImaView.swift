/*   Copyright 2018-2019 Prebid.org, Inc.
 
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

import Foundation
import GoogleInteractiveMediaAds

@objcMembers
public class VideoImaView: UIView, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {

    static let kTestAppContentUrl_MP4 = "https://google.com"
    
    static let kTestAppAdTagUrl =
        "https://pubads.g.doubleclick.net/gampad/ads?env=vp&gdfp_req=1&unviewed_position_start=1&output=vast&impl=s&" +
            "iu=/5300653/test_adunit_vast_direct_pavliuchyk&sz=640x480&" +
    "correlator=";
    
    var contentPlayhead: IMAAVPlayerContentPlayhead!
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    
    var contentPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    //initWithFrame to init view from code
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    //common func to init our view
    private func setupView() {
        setupContentPlayer()
        setupAdsLoader()
    }
    
    public func setupContentPlayer() {
        
        // Load AVPlayer with path to our content.
        guard let contentURL = URL(string: VideoImaView.kTestAppContentUrl_MP4) else {
            print("ERROR: please use a valid URL for the content URL")
            return
        }
        contentPlayer = AVPlayer(url: contentURL)
        
        // Create a player layer for the player.
        playerLayer = AVPlayerLayer(player: contentPlayer)
        
        // Size, position, and display the AVPlayer.
        playerLayer?.frame = self.layer.bounds
        self.layer.addSublayer(playerLayer!)
        
        // Set up our content playhead and contentComplete callback.
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: contentPlayer)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(VideoImaView.contentDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: contentPlayer?.currentItem);
    }
    
    func setupAdsLoader() {
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = self
    }
    
    public func requestAds() {
        // Create ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: self, companionSlots: nil)
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: VideoImaView.kTestAppAdTagUrl,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        
        adsLoader.requestAds(with: request)
    }
    
    // MARK: - NotificationCenter AVPlayerItemDidPlayToEndTime
    
    func contentDidFinishPlaying(_ notification: Notification) {
        // Make sure we don't call contentComplete as a result of an ad completing.
        if (notification.object as! AVPlayerItem) == contentPlayer?.currentItem {
            adsLoader.contentComplete()
        }
    }
    
    // MARK: - IMAAdsLoaderDelegate
    
    public func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
        adsManager = adsLoadedData.adsManager
        adsManager.delegate = self
        
        // Create ads rendering settings
        let adsRenderingSettings = IMAAdsRenderingSettings()
//        tell the SDK to use the in-app browser.
//        adsRenderingSettings.webOpenerPresentingController = self
        
        // Initialize the ads manager.
        adsManager.initialize(with: adsRenderingSettings)
    }
    
    public func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        print("Error loading ads: \(adErrorData.adError.message ?? "")")
        contentPlayer?.play()
    }
    
    // MARK: - IMAAdsManagerDelegate
    
    public func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        if event.type == IMAAdEventType.LOADED {
            // When the SDK notifies us that ads have been loaded, play them.
            adsManager.start()
        }
        
        logMessage("AdsManager event ---> \(event.typeString!)")
        
        switch (event.type) {
        case IMAAdEventType.LOADED:
            
            break
        case IMAAdEventType.PAUSE:
            
            break
        case IMAAdEventType.RESUME:
            
            break
        case IMAAdEventType.TAPPED:
            
            break
        default:
            break
        }
    }
    
    public func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        // Something went wrong with the ads manager after ads were loaded. Log the error and play the
        // content.
        logMessage("AdsManager error: \(error.message)")
        contentPlayer?.play()
    }
    
    public func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        // The SDK is going to play ads, so pause the content.
        contentPlayer?.pause()
    }
    
    public func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        // The SDK is done playing ads (at least for now), so resume the content.
        contentPlayer?.play()
    }
    
    
    // MARK: - Utility methods
    func logMessage(_ log: String!) {
        NSLog(log)
    }
}
