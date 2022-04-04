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

enum IntegrationKind: String, CaseIterable {
    
    case originalGAM    = "GAM"
    case originalAdMob = "AdMob"
    
    case inApp          = "In-App"
    case renderingGAM   = "GAM (R)"
    case renderingAdMob = "AdMob (R)"
    
    case undefined      = "Undefined"
}


class IndexController: UIViewController {
    
    @IBOutlet var adServerSegment: UISegmentedControl!
    
    @IBOutlet var bannerVideo: UIButton!
    @IBOutlet var interstitialVideo: UIButton!
    @IBOutlet weak var bannerNative: UIButton!
    @IBOutlet weak var inAppNative: UIButton!
    @IBOutlet weak var instreamVideo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Prebid Demo"
        
        adServerSegment.removeAllSegments()
        
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
        IntegrationKind
            .allCases
            .filter { $0 != .undefined }
            .forEach {
                adServerSegment.insertSegment(withTitle: $0.rawValue, at: adServerSegment.numberOfSegments, animated: false)
        }
        
        adServerSegment.selectedSegmentIndex = IntegrationKind
            .allCases
            .firstIndex(of: .inApp) ?? 0
        
        updateCasesList(for: .inApp)
    }
    
    @IBAction func onAdServerSwidshed(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        
        let integrationKind = IntegrationKind.allCases[index]
        
        updateCasesList(for: integrationKind)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let adServerName = adServerSegment.titleForSegment(at: adServerSegment.selectedSegmentIndex)!
        
        var buttonText = ""
        if let button = sender as? UIButton, let text = button.titleLabel?.text {
           buttonText = text
        }
        
        let integrationKind = IntegrationKind(rawValue: adServerName) ?? .undefined
        
        switch segue.destination {
            
        case let vc as BannerController:
            vc.integrationKind = integrationKind
            
            if buttonText == "Banner Video" {
                vc.bannerFormat = .vast
            }
            
        case let vc as InterstitialViewController:
            vc.integrationKind = integrationKind
            
            if buttonText == "Interstitial Video" {
                vc.adFormat = .vast
            }
            
        case let vc as NativeViewController:
            vc.integrationKind = integrationKind
            
        case let vc as RewardedVideoController:
            vc.integrationKind = integrationKind

        case let vc as NativeInAppViewController:
            vc.integrationKind = integrationKind

        case let vc as InstreamVideoViewController:
            vc.integrationKind = integrationKind

        default:
            print("wrong controller")

        }
    }
    
    func updateCasesList(for integrationKind: IntegrationKind) {
        
        let isRendering =   integrationKind == .inApp ||
                            integrationKind == .renderingGAM
                
        bannerNative.isHidden   = isRendering
        inAppNative.isHidden    = isRendering
        instreamVideo.isHidden  = isRendering
    }

}
