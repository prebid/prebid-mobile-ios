/*   Copyright 2018-2024 Prebid.org, Inc.

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
@testable import PrebidMobile

class MockPrebidMobilePluginRenderer: PrebidMobilePluginRenderer {
    
    let name: String
    let version: String
    var data: [String: Any]?
    
    init(name: String, version: String, data: [String: Any]? = nil) {
        self.name = name
        self.version = version
        self.data = data
    }
    
    func jsonDictionary() -> [String: Any] {
        var json: [String: Any] = ["name": name, "version": version]
        json["data"] = data
        return json
    }
    
    func createBannerView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: any DisplayViewLoadingDelegate,
        interactionDelegate: any DisplayViewInteractionDelegate
    ) -> (any UIView & PrebidMobileDisplayViewProtocol)? {
        return nil
    }
    
    func createInterstitialController(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: any InterstitialControllerLoadingDelegate,
        interactionDelegate: any InterstitialControllerInteractionDelegate
    ) -> (any PrebidMobileInterstitialControllerProtocol)? {
        return nil
    }
}
