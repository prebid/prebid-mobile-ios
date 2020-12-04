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

import UIKit
import GoogleInteractiveMediaAds
import PrebidMobile

class InstreamVideoViewController: UIViewController, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    
    @IBOutlet var adServerLabel: UILabel!
    
    @IBOutlet var appInstreamView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    var adServerName: String = ""
    let parameters = VideoBaseAdUnit.Parameters()
    var adUnitID: String!
    
    private var adUnit: VideoAdUnit!
    
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager?
    
    var contentPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?

    var contentPlayhead: IMAAVPlayerContentPlayhead?
    
    static let kTestAppContentUrl_MP4 = "https://storage.googleapis.com/gvabox/media/samples/stock.mp4"

    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.layer.zPosition = CGFloat.greatestFiniteMagnitude
        adServerLabel.text = adServerName
        setUpContentPlayer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        playerLayer?.frame = self.appInstreamView.layer.bounds
        adsManager?.destroy()
        contentPlayer?.pause()
        contentPlayer = nil
    }
    
    @IBAction func onPlayButtonTouch(_ sender: AnyObject) {
        if (adServerName == "DFP") {
            setupAndLoadAMInstreamVideo()
            
        } else if (adServerName == "MoPub") {
            contentPlayer?.play()
            print("mopub not supported")
        }
        
        playButton.isHidden = true
    }
    
    func setUpContentPlayer() {
        // Load AVPlayer with path to our content.
        guard let contentURL = URL(string: InstreamVideoViewController.kTestAppContentUrl_MP4) else {
            print("ERROR: please use a valid URL for the content URL")
            return
        }
        contentPlayer = AVPlayer(url: contentURL)
        
        // Create a player layer for the player.
        playerLayer = AVPlayerLayer(player: contentPlayer)
        
        // Size, position, and display the AVPlayer.
        playerLayer?.frame = appInstreamView.layer.bounds
        appInstreamView.layer.addSublayer(playerLayer!)
        
        // Set up our content playhead and contentComplete callback.
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: contentPlayer)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(InstreamVideoViewController.contentDidFinishPlaying(_:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: contentPlayer?.currentItem)
    }
    
    @objc func contentDidFinishPlaying(_ notification: Notification) {
        // Make sure we don't call contentComplete as a result of an ad completing.
        if (notification.object as! AVPlayerItem) == contentPlayer?.currentItem {
            adsLoader.contentComplete()
        }
    }
    
    func setupAndLoadAMInstreamVideo() {
        setupVideoParameters()
        
        //AppNexus
//        setupPBAppNexusInStreamVideo()
//        setupAMAppNexusInstreamVideo()
        
        //Rubicon
        setupPBRubiconInStreamVideo()
        setupAMRubiconInstreamVideo()
        
        loadAMInStreamVideo()
    }

    func setupVideoParameters() {
        parameters.mimes = ["video/mp4"]
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOn]
    }
    
    //Setup PB
    func setupPBAppNexusInStreamVideo() {
        setupPB(host: .Appnexus, accountId: "aecd6ef7-b992-4e99-9bb8-65e2d984e1dd", storedResponse: "")

        let videoAdUnit = VideoAdUnit(configId: "2c0af852-a55d-49dc-a5ca-ef7e141f73cc", size: CGSize(width: 1,height: 1))
        videoAdUnit.parameters = parameters
        adUnit = videoAdUnit
    }
    
    func setupPBRubiconInStreamVideo() {
        setupPB(host: .Rubicon, accountId: "1001", storedResponse: "sample_video_response")
        
        let videoAdUnit = VideoAdUnit(configId: "1001-1", size: CGSize(width: 1, height: 1))
        videoAdUnit.parameters = parameters
        adUnit = videoAdUnit
    }
    
    func setupPB(host: PrebidHost, accountId: String, storedResponse: String) {
        Prebid.shared.prebidServerHost = host
        Prebid.shared.prebidServerAccountId = accountId
        Prebid.shared.storedAuctionResponse = storedResponse
    }

    //Setup AdServer
    func setupAMAppNexusInstreamVideo() {
        adUnitID = "/19968336/Punnaghai_Instream_Video1"
    }
    
    func setupAMRubiconInstreamVideo() {
        adUnitID = "/5300653/test_adunit_vast_pavliuchyk"
    }
    
    func loadAMInStreamVideo() {
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = self
        
        adUnit.fetchDemand { (ResultCode, prebidKeys: [String : String]?) in
            print("prebid keys")
            if (ResultCode == .prebidDemandFetchSuccess){
                do {
                    let adServerTag = try IMAUtils.shared.generateInstreamUriForGAM(adUnitID: self.adUnitID, adSlotSizes: [.Size640x480,.Size400x300], customKeywords: prebidKeys!)
                    let adDisplayContainer = IMAAdDisplayContainer(adContainer: self.appInstreamView)
                    // Create an ad request with our ad tag, display container, and optional user context.
                    let request = IMAAdsRequest(adTagUrl: adServerTag, adDisplayContainer: adDisplayContainer, contentPlayhead: nil, userContext: nil)
                    self.adsLoader.requestAds(with: request)
                } catch {
                    print(error)
                    self.contentPlayer?.play()
                }
            } else {
                print("Error constructing IMA Tag")
                self.contentPlayer?.play()
            }
        }
    }
    
    //MARK: - IMAAdsLoaderDelegate
    func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
        adsManager = adsLoadedData.adsManager
        adsManager?.delegate = self

        // Create ads rendering settings and tell the SDK to use the in-app browser.
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.webOpenerPresentingController = self

        // Initialize the ads manager.
        adsManager?.initialize(with: adsRenderingSettings)
    }
    
    func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        print("Error loading ads: \(adErrorData.adError.message ?? "nil")")
        contentPlayer?.play()
    }
    
    //MARK: - IMAAdsManagerDelegate
    func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        if event.type == IMAAdEventType.LOADED {
            // When the SDK notifies us that ads have been loaded, play them.
            adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        print("AdsManager error: \(error.message ?? "nil")")
        contentPlayer?.play()
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        // The SDK is going to play ads, so pause the content.
        contentPlayer?.pause()
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        // The SDK is done playing ads (at least for now), so resume the content.
        contentPlayer?.play()
    }

}
