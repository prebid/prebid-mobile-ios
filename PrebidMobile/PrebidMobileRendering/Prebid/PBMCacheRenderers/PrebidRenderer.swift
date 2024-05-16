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

public class PrebidRenderer: NSObject, PrebidMobilePluginRenderer {
    
    public let name = "PrebidRenderer"
    
    public let version = Prebid.shared.version
    
    public let token: String? = nil
    
    public func isSupportRendering(for format: AdFormat?) -> Bool {
        (format == .banner || format == .video || format == .native)
    }
   
    public func setupBid(_ bid: Bid, adConfiguration: AdUnitConfig, connection: PrebidServerConnectionProtocol, callback: @escaping (PBMTransaction?, Error?) -> Void) {
    }
    
    public func createBannerAdView(with frame: CGRect, bid: Bid, configId: String, adViewDelegate: (any PBMAdViewDelegate)?) {
        
    }
    
    public func createInterstitialController(bid: Bid, configId: String, adViewDelegate: (any PBMAdViewDelegate)?) {
    }
}
