//
//  InstreamVideoViewController.swift
//  PrebidDemoSwift
//
//  Created by Punnaghai Puviarasu on 9/28/20.
//  Copyright © 2020 Prebid. All rights reserved.
//

import UIKit
import GoogleInteractiveMediaAds
import PrebidMobile

class InstreamVideoViewController: UIViewController, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
    
    @IBOutlet var adServerLabel: UILabel!
    
    @IBOutlet var appInstreamView: UIView!
    
    var adServerName: String = ""
    
    private var adUnit: AdUnit!
    
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    
//    static let kTestAppAdTagUrl =
//    "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&"
//    + "iu=/19968336/Punnaghai_Instream_Video1&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&"
//    + "output=vast&unviewed_position_start=1&"
//    + "cust_params=sample_ct%3Dlinear%26hb_uuid_appnexus%3Dd2913b6a-6abb-4451-941c-12657097c5bc%26hb_cache_host%3Dprebid.nym2.adnxs.com&hb_bidder_appnexus%3Dappnexus%26hb_size_appnexus%3D1x1%26hb_pb_appnexus%3D0.50%26hb_cache_path%3D/pbc/v1/cache%26hb_pb%3D0.50%26hb_cache_path_appnex%3D/pbc/v1/cache%26hb_uuid%3Dd2913b6a-6abb-4451-941c-12657097c5bc%26hb_size%3D1x1%26hb_env%3Dmobile-app%26hb_env_appnexus%3Dmobile-app%26hb_bidder%3Dappnexus%26hb_cache_host_appnex%3Dprebid.nym2.adnxs.com"
    
    static let kTestAppAdTagUrl =
    "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&"
    + "iu=/19968336/Punnaghai_Instream_Video1&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&"
    + "output=vast&unviewed_position_start=1&"
    + "cust_params=sample_ct%3Dlinear%26hb_uuid%3Df3727302-e689-4ecc-800e-b966bed76e87"
    
    private let amAppNexusAdUnitId = "/19968336/Punnaghai_Instream_Video1"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adServerLabel.text = adServerName
        
        if (adServerName == "DFP") {
            setupAndLoadAMRewardedVideo()
        } else if (adServerName == "MoPub") {
           
        }

        // Do any additional setup after loading the view.
    }
    
    func setupAndLoadAMRewardedVideo() {
        setupPBAppNexusInStreamVideo()
        setupAMAppNexusInstreamVideo()
        
    }
    
    //Setup PB
    func setupPBAppNexusInStreamVideo() {

        setupPB(host: .Appnexus, accountId: "aecd6ef7-b992-4e99-9bb8-65e2d984e1dd", storedResponse: "sample_video_response")

        let adUnit = VideoAdUnit(configId: "2c0af852-a55d-49dc-a5ca-ef7e141f73cc", size: CGSize(width: 1, height: 1))
        
        let parameters = VideoBaseAdUnit.Parameters()
        parameters.mimes = ["video/mp4"]
        
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        
        adUnit.parameters = parameters
        
        self.adUnit = adUnit
        
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
        
//        self.adUnit.fetchDemand() { [weak self] (resultCode: ResultCode) in
//            print("Prebid demand fetch for AdManager \(resultCode.name())")
//            self?.amBanner.load(self?.amRequest)
//        }
        
        // Create ad display container for ad rendering.
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: appInstreamView)
        // Create an ad request with our ad tag, display container, and optional user context.
        let request = IMAAdsRequest(adTagUrl: InstreamVideoViewController.kTestAppAdTagUrl, adDisplayContainer: adDisplayContainer, contentPlayhead: nil, userContext: nil)
        adsLoader.requestAds(with: request)
        
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
