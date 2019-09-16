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
public class VideoImaView: UIView, VideoImaPrivateDelegate {
    
    public weak var delegate: VideoImaDelegate? {
        didSet {
            imaDelegate.videoImaDelegate = delegate
        }
    }
    
    fileprivate var imaDelegate: ImaDelegate!
    
    private static let contentUrlDummy = URL(string: "https://google.com")!

    private var contentPlayhead: IMAAVPlayerContentPlayhead?
    private var adsLoader: IMAAdsLoader!
    private var adsManager: IMAAdsManager!
    
    private var contentPlayer: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    //initWithFrame to init view from code
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    //initWithCode to init view from xib or storyboard
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        imaDelegate = ImaDelegate(videoImaPrivateDelegate: self)
        setupPlayerAndLoader()
    }
    
    //common func to init our view
    private func setupPlayerAndLoader() {
        
        setupContentPlayer()
        setupAdsLoader()
    }
    
    private func setupContentPlayer() {
        
        if (contentPlayer != nil) {
            return
        }
        
        // Load AVPlayer with path to our content.
        contentPlayer = AVPlayer(url: VideoImaView.contentUrlDummy)
        
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
            object: contentPlayer.currentItem);
    }
    
    fileprivate func setupAdsLoader() {
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = imaDelegate
    }
    
    fileprivate func setupAdsManager(adsLoadedData: IMAAdsLoadedData) {
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
        adsManager = adsLoadedData.adsManager
        adsManager.delegate = imaDelegate
        
        // Create ads rendering settings
        let adsRenderingSettings = IMAAdsRenderingSettings()
//        tell the SDK to use the in-app browser.
//        adsRenderingSettings.webOpenerPresentingController = self
        
        // Initialize the ads manager.
        adsManager.initialize(with: adsRenderingSettings)
    }
    
    // MARK: - Public API
    public func requestAds(adUnitId: String, targeting: Dictionary<String, String>) {
        
        let adTagUrl = VideoUtils.buildAdTagUrl(adUnitId: adUnitId, targeting: targeting)
        
        requestAds(adTagUrl: adTagUrl)
    }
    
    public func requestAds(adTagUrl: String) {
        resetAdsManager()
        
        setupPlayerAndLoader()
        
        // Create ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: self, companionSlots: nil)
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(
            adTagUrl: adTagUrl,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil)
        
        adsLoader.requestAds(with: request)
    }
    
    public func reset() {
        resetContentPlayer()
        resetAdsLoader()
        resetAdsManager()
    }
    
    // MARK: - private API
    private func resetContentPlayer() {
        contentPlayer = nil
    }
    
    private func resetAdsLoader() {
        adsLoader.delegate = nil
        adsLoader = nil
    }
    
    private func resetAdsManager() {
        if (adsManager != nil) {
            adsManager.destroy()
            adsManager = nil
        }
    }
    
    // MARK: - NotificationCenter AVPlayerItemDidPlayToEndTime
    
    func contentDidFinishPlaying(_ notification: Notification) {
        // Make sure we don't call contentComplete as a result of an ad completing.
        if (notification.object as! AVPlayerItem) == contentPlayer.currentItem {
            adsLoader.contentComplete()
        }
    }
    
    //MARK: - VideoImaPrivateDelegate
    func adLoaded(adsLoadedData: IMAAdsLoadedData) {
        setupAdsManager(adsLoadedData: adsLoadedData)
    }

}

private protocol VideoImaPrivateDelegate: class {
    func adLoaded(adsLoadedData: IMAAdsLoadedData)
}

// MARK: - IMA API
private class ImaDelegate: NSObject, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {

    fileprivate weak var videoImaDelegate: VideoImaDelegate?
    
    private weak var videoImaPrivateDelegate: VideoImaPrivateDelegate?
    
    fileprivate init(videoImaPrivateDelegate: VideoImaPrivateDelegate) {
        self.videoImaPrivateDelegate = videoImaPrivateDelegate
    }
    
    // MARK: - IMAAdsLoaderDelegate
    public func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        
        videoImaDelegate?.videoIma(event: VideoImaAdEventFactory.getAdLoadSuccess(typeString: nil))
        
        videoImaPrivateDelegate?.adLoaded(adsLoadedData: adsLoadedData)
        
        Log.debug("adsLoader success")
    }
    
    public func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        
        let errorMessage = adErrorData.adError.message
        videoImaDelegate?.videoIma(event: VideoImaAdEventFactory.getAdLoadFail(typeString: errorMessage))
        
        Log.debug("adsLoader failed:\(errorMessage ?? "")")
    }
    
    // MARK: - IMAAdsManagerDelegate
    public func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        
        let message = event.typeString
        Log.debug("adsManager eventType:\(message ?? "")")
        
        //Logic
        if event.type == IMAAdEventType.LOADED {
            // When the SDK notifies us that ads have been loaded, play them.
            adsManager.start()
        }
        
        let eventString = event.typeString
        //Event handler
        switch (event.type) {
        case IMAAdEventType.STARTED:
            videoImaDelegate?.videoIma(event: VideoImaAdEventFactory.getAdStarted(typeString: eventString))
            break
        case IMAAdEventType.COMPLETE:
            videoImaDelegate?.videoIma(event: VideoImaAdEventFactory.getAdDidReachEnd(typeString: eventString))
            break
        case IMAAdEventType.TAPPED:
            videoImaDelegate?.videoIma(event: VideoImaAdEventFactory.getAdClicked(typeString: eventString))
            break
        default:
            break
        }
    }
    
    public func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        // Something went wrong with the ads manager after ads were loaded. Log the error and play the
        // content.
        let errorMessage = error.message
        Log.debug("AdsManager error:\(errorMessage ?? "")")
        
        videoImaDelegate?.videoIma(event: VideoImaAdEventFactory.getAdInternalError(typeString: errorMessage))
        //        contentPlayer.play()
    }
    
    public func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        // The SDK is going to play ads.
    }
    
    public func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        // The SDK is done playing ads (at least for now)
    }
}
