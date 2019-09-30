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
import GoogleMobileAds

class VideoOutStreamViewController: UIViewController, PBVideoAdDelegate {

    @IBOutlet var videoImaView: VideoImaView!
    
    @IBOutlet var playerConsole: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPrebid()

        videoImaView.pbVideoAdDelegate = self
    }

    private func setupPrebid() {
        Prebid.shared.prebidServerHost = PrebidHost.Custom
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid-server.qa.rubiconproject.com/openrtb2/auction")
        Prebid.shared.prebidServerAccountId = "1001_top_level_video"
        Prebid.shared.storedAuctionResponse = "1001_video_response"
    }
    
    //MARK: - IB Actions
    @IBAction func onPlay(_ sender: Any) {
        
        playerConsole.text = ""
        logMessage("request ad")
        
        let adSlotSize = CGSize(width: 640, height: 480)
        let videoAdUnit = VideoAdUnit(configId: "1001_test_video", size: adSlotSize)
        videoImaView.loadAd(videoAdUnit: videoAdUnit, adUnitId: "/5300653/test_adunit_vast_pavliuchyk")
        
    }
    
    // MARK: - Disappear
    override func viewWillDisappear(_ animated: Bool) {
        
        videoImaView.reset()
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - PBVideoDelegate
    func videoAd(event: PBVideoAdEvent) {
        logMessage("videoAd event:\(event.typeString)")
    }
    
    // MARK: Utility methods
    func logMessage(_ log: String) {
        NSLog(log)
        
        playerConsole.text = playerConsole.text + ("\n\(log)\n ")
        
        //scroll
        if playerConsole.text.count > 0 {
            let location = playerConsole.text.count - 1
            let bottom = NSMakeRange(location, 1)
            playerConsole.scrollRangeToVisible(bottom)
            
            playerConsole.isScrollEnabled = false
            playerConsole.isScrollEnabled = true
        }
    }
}


