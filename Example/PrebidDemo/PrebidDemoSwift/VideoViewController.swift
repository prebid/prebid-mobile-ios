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

class VideoViewController: UIViewController, VideoImaDelegate {

    @IBOutlet var videoImaView: VideoImaView!
    
    @IBOutlet var playerConsole: UITextView!

    @IBOutlet var playerSizeSlider: UISlider!
    
    var videoAdUnit: VideoAdUnit!
    
    //resize feture
    var originalFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalFrame = videoImaView.frame
        
        setupPrebid()

        videoImaView.delegate = self
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        let currentVideoFrame = videoImaView.frame
        
        let playerScale = playerSizeSlider.value
        
        let width = CGFloat(currentVideoFrame.width / CGFloat(playerScale))
        let height = CGFloat(currentVideoFrame.height / CGFloat(playerScale))
        
        let x = currentVideoFrame.origin.x - ((width - currentVideoFrame.width) / 2)
        let y = currentVideoFrame.origin.y - ((height - currentVideoFrame.height) / 2)
        
        originalFrame = CGRect(x: x, y: y, width: width, height: height)

    }

    private func setupPrebid() {
        Prebid.shared.storedAuctionResponse = "1001_video_response"
        Prebid.shared.prebidServerHost = PrebidHost.Custom
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid-server.qa.rubiconproject.com/openrtb2/auction")
        Prebid.shared.prebidServerAccountId = "1001_top_level_video"
    }
    
    //MARK: - IB Actions
    @IBAction func onPlay(_ sender: Any) {
        
        playerConsole.text = ""
        
        videoAdUnit = VideoAdUnit(configId: "1001_test_video", size: CGSize(width: 300, height: 250))
        
        let request = DFPRequest()
        
        logMessage("Auction request")
        videoAdUnit.fetchDemand(adObject: request) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            
            if (resultCode == .prebidDemandFetchSuccess) {
                let keywords = request.value(forKey: "customTargeting") as! Dictionary<String, String>
                self?.logMessage("keywords:\(keywords)")
                
                self?.logMessage("AdManager request")
                self?.videoImaView.requestAds(adUnitId: "/5300653/test_adunit_vast_pavliuchyk", targeting: keywords)
            }
        }
        
    }
    
    @IBAction func onPlayerSize(_ sender: UISlider) {

        let playerScale = sender.value
        let width = CGFloat(originalFrame.width * CGFloat(playerScale))
        let height = CGFloat(originalFrame.height * CGFloat(playerScale))
        
        let x = originalFrame.origin.x + (originalFrame.width - width) / 2
        let y = originalFrame.origin.y + (originalFrame.height - height) / 2
        
        videoImaView.frame = CGRect(x: x, y: y, width: width, height: height)
        
    }
    
    // MARK: - Disappear
    override func viewWillDisappear(_ animated: Bool) {
        
        videoImaView.reset()
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: - VideoImaDelegate
    func videoIma(event: VideoImaAdEvent) {
        logMessage("eventString:\(event.typeString)")
    }
    
    // MARK: Utility methods
    func logMessage(_ log: String) {
        playerConsole.text = playerConsole.text + ("\n\(log)\n")
        NSLog(log)
        
        //scroll
        if (playerConsole.text.count > 0) {
            let bottom = NSMakeRange(playerConsole.text.count - 1, 1)
            playerConsole.scrollRangeToVisible(bottom)
        }
    }
}


