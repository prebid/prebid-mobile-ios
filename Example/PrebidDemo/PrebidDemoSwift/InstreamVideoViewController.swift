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
    
    var adServerName: String = ""
    
    private var adUnit: VideoAdUnit!
    
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    
    private let amAppNexusAdUnitId = "/19968336/Punnaghai_Instream_Video1"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adServerLabel.text = adServerName
        
        if (adServerName == "DFP") {
            setupAndLoadAMInstreamVideo()
        } else if (adServerName == "MoPub") {
           print("mopub not supported")
        }

        // Do any additional setup after loading the view.
    }
    
    func setupAndLoadAMInstreamVideo() {
        setupPBAppNexusInStreamVideo()
        setupAMAppNexusInstreamVideo()
        
    }
    
    //Setup PB
    func setupPBAppNexusInStreamVideo() {

        setupPB(host: .Appnexus, accountId: "aecd6ef7-b992-4e99-9bb8-65e2d984e1dd", storedResponse: "sample_video_response")

        let videoAdUnit = VideoAdUnit(configId: "2c0af852-a55d-49dc-a5ca-ef7e141f73cc", size: CGSize(width: 1,height: 1))
        
        let parameters = VideoBaseAdUnit.Parameters()
        parameters.mimes = ["video/mp4"]
        
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOn]
        
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
        
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader.delegate = self
        
        adUnit.fetchDemand { (ResultCode, prebidKeys: [String : String]?) in
            print("prebid keys")
            if(ResultCode == .prebidDemandFetchSuccess){
                let adServerTag:String = IMAUtils.shared.constructAdTagURLForIMAWithPrebidKeys(adUnitID: "/19968336/Punnaghai_Instream_Video1", customKeywords: prebidKeys!)
                let adDisplayContainer = IMAAdDisplayContainer(adContainer: self.appInstreamView)
                // Create an ad request with our ad tag, display container, and optional user context.
                let request = IMAAdsRequest(adTagUrl: adServerTag, adDisplayContainer: adDisplayContainer, contentPlayhead: nil, userContext: nil)
                self.adsLoader.requestAds(with: request)
            } else {
                print ("Error constructing IMA Tag")
            }
        }
        
    }
    
    //adsLoader delegate
    func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
        adsManager = adsLoadedData.adsManager
        adsManager.delegate = self

        // Create ads rendering settings and tell the SDK to use the in-app browser.
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.webOpenerPresentingController = self

        // Initialize the ads manager.
        adsManager.initialize(with: adsRenderingSettings)
    }
    
    func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        print("Error loading ads: \(adErrorData.adError.message ?? "nil")")
    }
    
    //adsManager delegate
    func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        if event.type == IMAAdEventType.LOADED {
          // When the SDK notifies us that ads have been loaded, play them.
          adsManager.start()
        }
    }
    
    func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        print("AdsManager error: \(error.message ?? "nil")")
    }
    
    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        
    }
    
    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        
    }

}
