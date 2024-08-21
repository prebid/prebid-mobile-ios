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
import Foundation
import PrebidMobile
import UIKit

public class SampleCustomRenderer: NSObject, PrebidMobilePluginRenderer {
    
    public let name = "SampleCustomRenderer"
    
    public let version = "1.0.0"
    
    public var data: [AnyHashable: Any]? = nil
    
    private var adViewManager: PBMAdViewManager?
    
    public func isSupportRendering(for format: AdFormat?) -> Bool {
        AdFormat.allCases.contains(where: { $0 == format })
    }
   
    public func setupBid(_ bid: Bid, adConfiguration: AdUnitConfig, connection: PrebidServerConnectionProtocol) {
        
    }
    
    public func createBannerAdView(with frame: CGRect, bid: Bid, adConfiguration: AdUnitConfig,
                                   connection: PrebidServerConnectionProtocol, adViewDelegate: (any PBMAdViewDelegate)?) {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
               let rootView = window.rootViewController?.view {
                if let prebidBannerView = self.findPrebidBannerView(in: rootView) {
                    print("Found PrebidBannerView: \(prebidBannerView)")
                    
                    let label = UILabel()
                    label.text = "Prebid SDK - Custom Renderer"
                    label.textAlignment = .center
                    label.textColor = .black
                    label.backgroundColor = .yellow
                    label.translatesAutoresizingMaskIntoConstraints = false
                    
                    prebidBannerView.addSubview(label)
                    
                    NSLayoutConstraint.activate([
                        label.centerXAnchor.constraint(equalTo: prebidBannerView.centerXAnchor),
                        label.centerYAnchor.constraint(equalTo: prebidBannerView.centerYAnchor),
                        label.widthAnchor.constraint(equalTo: prebidBannerView.widthAnchor),
                        label.heightAnchor.constraint(equalTo: prebidBannerView.heightAnchor)
                    ])
                    
                } else {
                    print("PrebidBannerView not found.")
                }
            }
        }
    }
    
    private func findPrebidBannerView(in view: UIView) -> UIView? {
        if view.accessibilityIdentifier == "PrebidBannerView" {
            return view
        }
        for subview in view.subviews {
            if let foundView = findPrebidBannerView(in: subview) {
                return foundView
            }
        }
        return nil
    }

    public func createInterstitialController(bid: Bid, adConfiguration: AdUnitConfig, connection: PrebidServerConnectionProtocol,
                                             adViewManagerDelegate adViewDelegate: InterstitialController?, videoControlsConfig: VideoControlsConfiguration?) {
    }
}
