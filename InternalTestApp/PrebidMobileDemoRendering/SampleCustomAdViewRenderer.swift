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

public class SampleCustomBannerViewRenderer: NSObject, PrebidMobilePluginRenderer {
    
    public let name = "SampleCustomBannerViewRenderer"
    public let version = "1.0.0"
    public var data: [AnyHashable: Any]?
    
    public func isSupportRendering(for format: AdFormat?) -> Bool {
        AdFormat.allCases.contains(where: { $0 == format })
    }
    
    private weak var loadingDelegate: DisplayViewLoadingDelegate?
    private weak var interactionDelegate: DisplayViewInteractionDelegate?
    private weak var currentAdView: UIView?
    
    public func createBannerAdView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        connection: PrebidServerConnectionProtocol,
        loadingDelegate: DisplayViewLoadingDelegate?,
        interactionDelegate: DisplayViewInteractionDelegate?
    ) -> UIView {
        
        self.interactionDelegate = interactionDelegate
        self.loadingDelegate = loadingDelegate
        
        let bannerView = UIView(frame: frame)
        
        let label = UILabel()
        label.text = "Prebid SDK - Custom Renderer"
        label.textAlignment = .center
        label.textColor = .black
        label.backgroundColor = .yellow
        label.translatesAutoresizingMaskIntoConstraints = false
        
        bannerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: bannerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: bannerView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: bannerView.widthAnchor),
            label.heightAnchor.constraint(equalTo: bannerView.heightAnchor)
        ])
        
        currentAdView = bannerView
        
        loadingDelegate?.displayViewDidLoadAd(bannerView)
        
        return bannerView
    }
    
    public func createInterstitialController(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        connection: PrebidServerConnectionProtocol,
        adViewManagerDelegate adViewDelegate: InterstitialController?,
        videoControlsConfig: VideoControlsConfiguration?
    ) {}
}
