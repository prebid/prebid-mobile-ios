/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

fileprivate let storedImpDisplayInterstitial = "prebid-demo-display-interstitial-320-480-custom-interstitial-renderer"

class InAppDisplayInterstitialPluginRendererViewController:
    UIViewController,
    InterstitialAdUnitDelegate {
    
    // Prebid
    private var renderingInterstitial: InterstitialRenderingAdUnit!
    private let samplePluginRenderer = SampleRenderer()
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    deinit {
        // Unregister plugin when you no longer needed
        Prebid.unregisterPluginRenderer(samplePluginRenderer)
    }
    
    func createAd() {
        // 1. Register the plugin renderer
        Prebid.registerPluginRenderer(samplePluginRenderer)
        
        // 2. Create a InterstitialRenderingAdUnit
        renderingInterstitial = InterstitialRenderingAdUnit(configID: storedImpDisplayInterstitial)
        
        // 3. Configure the InterstitialRenderingAdUnit
        renderingInterstitial.adFormats = [.banner]
        renderingInterstitial.delegate = self
        
        // 4. Load the interstitial ad
        renderingInterstitial.loadAd()
    }
    
    // MARK: - InterstitialAdUnitDelegate
    
    func interstitialDidReceiveAd(_ interstitial: InterstitialRenderingAdUnit) {
        interstitial.show(from: self)
    }
    
    func interstitial(_ interstitial: InterstitialRenderingAdUnit, didFailToReceiveAdWithError error: Error?) {
        PrebidDemoLogger.shared.error("Interstitial Rendering ad unit did fail to receive ad with error: \(error)")
    }
}
