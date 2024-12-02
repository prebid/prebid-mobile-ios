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

public class PrebidDisplayViewRenderer: NSObject, PrebidMobileAdViewPluginRenderer {
    
    public let name = "PrebidDisplayViewRenderer"
    public let version = Prebid.shared.version
    public var data: [AnyHashable: Any]?
    
    public func isSupportRendering(for format: AdFormat?) -> Bool {
        [AdFormat.banner, AdFormat.video].contains(format)
    }
    
    public func createAdView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: DisplayViewLoadingDelegate,
        interactionDelegate: DisplayViewInteractionDelegate
    ) -> (UIView & PrebidMobileDisplayViewProtocol)? {
        let displayView = PBMDisplayView(
            frame: frame,
            bid: bid,
            adConfiguration: adConfiguration
        )
        
        displayView.interactionDelegate = interactionDelegate
        displayView.loadingDelegate = loadingDelegate
        
        return displayView
    }
}
