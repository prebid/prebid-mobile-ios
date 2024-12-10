/*   Copyright 2018-2024 Prebid.org, Inc.

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
import PrebidMobile

/// A custom implementation of the renderer.
public class SampleRenderer: NSObject, PrebidMobilePluginRenderer {
    
    public let name = "SampleRenderer"
    public let version = "1.0.0"
    public var data: [String: Any]?
    
    /// This method creates an instance of `SampleAdView`, which is a custom view used to display the ad. 
    public func createBannerView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: DisplayViewLoadingDelegate,
        interactionDelegate: DisplayViewInteractionDelegate
    ) -> (UIView & PrebidMobileDisplayViewProtocol)? {
        let adView = SampleAdView(frame: frame)
        
        adView.interactionDelegate = interactionDelegate
        adView.loadingDelegate = loadingDelegate
        adView.bid = bid
        
        return adView
    }
    
    /// This method creates an instance of `SampleInterstitialController`,
    /// a custom controller used to display interstitial ads.
    public func createInterstitialController(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: InterstitialControllerLoadingDelegate,
        interactionDelegate: InterstitialControllerInteractionDelegate
    ) -> PrebidMobileInterstitialControllerProtocol? {
        let interstitialController = SampleInterstitialController()
        
        interstitialController.loadingDelegate = loadingDelegate
        interstitialController.interactionDelegate = interactionDelegate
        interstitialController.bid = bid
        
        return interstitialController
    }
}
