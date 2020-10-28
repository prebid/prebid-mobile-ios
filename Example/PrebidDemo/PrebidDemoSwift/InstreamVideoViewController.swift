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
    
    private var adUnit: InStreamVideoAdUnit!
    
    var adsLoader: IMAAdsLoader!
    var adsManager: IMAAdsManager!
    
//    static let kTestAppAdTagUrl =
//    "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&"
//    + "iu=/19968336/Punnaghai_Instream_Video1&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&"
//    + "output=vast&unviewed_position_start=1&"
//    + "cust_params=sample_ct%3Dlinear%26hb_uuid_appnexus%3Dd2913b6a-6abb-4451-941c-12657097c5bc%26hb_cache_host%3Dprebid.nym2.adnxs.com&hb_bidder_appnexus%3Dappnexus%26hb_size_appnexus%3D1x1%26hb_pb_appnexus%3D0.50%26hb_cache_path%3D/pbc/v1/cache%26hb_pb%3D0.50%26hb_cache_path_appnex%3D/pbc/v1/cache%26hb_uuid%3Dd2913b6a-6abb-4451-941c-12657097c5bc%26hb_size%3D1x1%26hb_env%3Dmobile-app%26hb_env_appnexus%3Dmobile-app%26hb_bidder%3Dappnexus%26hb_cache_host_appnex%3Dprebid.nym2.adnxs.com"
    
    //env
    //gdfp_req
    //iu
    //output
    //sz - Size of master video ad slot.
    //unviewed_position_start - Setting this to 1 turns on delayed impressions for video.
    //cust_params
    
    static let kTestAppAdTagUrl =
    "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&"
    + "iu=/19968336/Punnaghai_Instream_Video1&gdfp_req=1&env=vp&"
    + "output=vast&unviewed_position_start=1&"
    + "cust_params=hb_size_appnexus%3D1x1%26hb_cache_id_appnexus%3D37a2083f-f7ab-4f75-9c68-ef6e65de60bb%26hb_uuid%3Dda6b9303-52fc-434b-96e1-786c7f006735%26hb_env_appnexus%3Dmobile-app%26hb_cache_host%3Dprebid.nym2.adnxs.com%26hb_cache_path%3D%2Fpbc%2Fv1%2Fcache%26hb_env%3Dmobile-app%26hb_size%3D1x1%26hb_cache_host_appnex%3Dprebid.nym2.adnxs.com%26hb_cache_id%3D37a2083f-f7ab-4f75-9c68-ef6e65de60bb%26hb_bidder_appnexus%3Dappnexus%26hb_bidder%3Dappnexus%26hb_pb_appnexus%3D0.50%26hb_cache_path_appnex%3D%2Fpbc%2Fv1%2Fcache%26hb_pb%3D0.50%26hb_uuid_appnexus%3Dda6b9303-52fc-434b-96e1-786c7f006735"
    
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

        let videoAdUnit = InStreamVideoAdUnit(configId: "2c0af852-a55d-49dc-a5ca-ef7e141f73cc")
        
        let parameters = VideoBaseAdUnit.Parameters()
        parameters.mimes = ["video/mp4"]
        
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        
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
        
        adUnit.fetchInstreamDemandForAdObject(adUnitId: "/19968336/Punnaghai_Instream_Video1") { (ResultCode, adServerTag: String?) in
            print("prebid keys")
            print(adServerTag!)
            let adDisplayContainer = IMAAdDisplayContainer(adContainer: self.appInstreamView)
            // Create an ad request with our ad tag, display container, and optional user context.
            if(ResultCode == .prebidDemandFetchSuccess){
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
