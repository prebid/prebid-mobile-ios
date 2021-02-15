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

import UIKit


class IndexController: UIViewController {
    @IBOutlet var adServerSegment: UISegmentedControl!
    @IBOutlet var bannerVideo: UIButton!
    @IBOutlet var interstitialVideo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Prebid Demo"
    }
    
    @IBAction func onAdServerSwidshed(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        
        switch index {
        case 0:
            bannerVideo.isHidden = false
        case 1:
            bannerVideo.isHidden = true
            
        default:
            bannerVideo.isHidden = false
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let adServerName = adServerSegment.titleForSegment(at: adServerSegment.selectedSegmentIndex)!
        
        var buttonText = ""
        if let button = sender as? UIButton, let text = button.titleLabel?.text {
           buttonText = text
        }
        
        switch segue.destination {
            
        case let vc as BannerController:
            vc.adServerName = adServerName
            
            if buttonText == "Banner Video" {
                vc.bannerFormat = .vast
            }
            
        case let vc as InterstitialViewController:
            vc.adServerName = adServerName
            
            if buttonText == "Interstitial Video" {
                vc.bannerFormat = .vast
            }
            
        case let vc as NativeViewController:
            vc.adServerName = adServerName
            
        case let vc as RewardedVideoController:
            vc.adServerName = adServerName
            
        case let vc as NativeInAppViewController:
            vc.adServerName = adServerName

        case let vc as InstreamVideoViewController:
            vc.adServerName = adServerName

        default:
            print("wrong controller")

        }
    }

}
