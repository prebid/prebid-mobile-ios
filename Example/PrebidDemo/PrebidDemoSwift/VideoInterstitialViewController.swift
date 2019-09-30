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
import Foundation
import PrebidMobile

class VideoInterstitialViewController: UIViewController, PBVideoAdInterstitialDelegate {
    
    @IBOutlet
    var showAd: UIButton!
    
    var videoImaInterstitial: VideoImaInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPrebid()
        
        videoImaInterstitial = VideoImaInterstitial()
        videoImaInterstitial.interstitialDelegate = self
        
        let adSlotSize = CGSize(width: 640, height: 480)
        let videoInterstitialAdUnit = VideoInterstitialAdUnit(configId: "1001_test_video", size: adSlotSize)
        
        videoImaInterstitial.loadAd(videoInterstitialAdUnit: videoInterstitialAdUnit, adUnitId: "/5300653/test_adunit_vast_pavliuchyk")

    }
    
    private func setupPrebid() {
        Prebid.shared.prebidServerHost = PrebidHost.Custom
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid-server.qa.rubiconproject.com/openrtb2/auction")
        Prebid.shared.prebidServerAccountId = "1001_top_level_video"
        Prebid.shared.storedAuctionResponse = "1001_video_response"
    }
    
    @IBAction
    func onShowAd(_ sender: UIButton) {
        videoImaInterstitial.show(from: self)
        
        showAd.isEnabled = false
    }
    
    // MARK: Utility methods
    func logMessage(_ log: String) {
        NSLog(log)
    }
    
    //MARK: - PBVideoAdInterstitialDelegate
    func videoAdInterstitialLoaded() {
        showAd.isEnabled = true
    }
    
    func videoAdInterstitialCancelled() {
        
    }
    
    func videoAdInterstitialCompleted() {
        
    }
    
    func videoAdInterstitialFailed() {
        
    }
    
    func videoAdInterstitial(event: PBVideoAdEvent) {
        logMessage("videoAdInterstitial event:\(event.typeString)")
    }

}
