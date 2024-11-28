/*   Copyright 2018-2021 Prebid.org, Inc.

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

public class SampleCustomAdViewRenderer: NSObject, PrebidMobileAdViewPluginRenderer {
    
    public let name = "SampleCustomAdViewRenderer"
    public let version = "1.0.0"
    public var data: [AnyHashable: Any]?
    
    public func isSupportRendering(for format: AdFormat?) -> Bool {
        AdFormat.allCases.contains(where: { $0 == format })
    }
    
    public func createAdView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: DisplayViewLoadingDelegate?,
        interactionDelegate: DisplayViewInteractionDelegate?
    ) -> UIView {
        let bannerView = SampleAdView(frame: frame)
        bannerView.interactionDelegate = interactionDelegate
        bannerView.loadingDelegate = loadingDelegate
        bannerView.displayAd(bid)
        return bannerView
    }
}
