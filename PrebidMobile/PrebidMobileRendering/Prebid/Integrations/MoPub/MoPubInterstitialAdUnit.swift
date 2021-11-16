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
import UIKit

@objcMembers
public class MoPubInterstitialAdUnit : MoPubBaseInterstitialAdUnit {
    
    // MARK: - Public Properties
    
    public var adFormat: AdFormat {
        get { adUnitConfig.adFormat }
        set { adUnitConfig.adFormat = newValue }
    }
    
    public var additionalSizes: [CGSize]? {
        get { adUnitConfig.additionalSizes }
        set { adUnitConfig.additionalSizes = newValue }
    }
    
    // MARK: - Public Methods
    
    public override convenience init(configId: String) {
        self.init(configId: configId, minSizePercentage: nil)
    }
    
    public init(configId: String, minSizePercentage: CGSize?) {
        super.init(configId: configId)
        
        if let size = minSizePercentage {
            adUnitConfig.minSizePerc = NSValue(cgSize: size)
        }
    }
    
    // MARK: - Computed Properties
    
    public override var configId: String {
        adUnitConfig.configID
    }
}
