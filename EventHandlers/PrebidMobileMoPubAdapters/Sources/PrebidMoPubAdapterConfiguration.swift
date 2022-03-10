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

import MoPubSDK

import PrebidMobile

@objc(PrebidMoPubAdapterConfiguration)
public class PrebidMoPubAdapterConfiguration : MPBaseAdapterConfiguration {
    
    // MARK: - MPAdapterConfiguration
    
    public override var adapterVersion: String {
        "\(PrebidConfiguration.shared.version).\(Constants.adapterVersion)"
    }
    
    public override var networkSdkVersion: String {
        PrebidConfiguration.shared.version
    }
    
    // NOTE: absence of this property may lead to crash
    public override var moPubNetworkName: String {
        Constants.mopubNetworkName
    }
    
    public override var biddingToken: String? {
        nil
    }
    
    public override func initializeNetwork(withConfiguration configuration: [String : Any]?, complete: ((Error?) -> Void)? = nil) {
        PrebidConfiguration.initializeRenderingModule()
        
        PrebidConfiguration.shared.logLevel = .info
        PrebidConfiguration.shared.locationUpdatesEnabled = true
        PrebidConfiguration.shared.creativeFactoryTimeout = 15
        
        complete?(nil)
    }
 }
