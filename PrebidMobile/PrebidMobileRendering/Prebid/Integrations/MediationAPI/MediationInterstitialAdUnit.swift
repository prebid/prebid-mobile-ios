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
public class MediationInterstitialAdUnit : MediationBaseInterstitialAdUnit {
    
    // MARK: - Public Properties
    
    public var adFormats: Set<AdFormat> {
        get { adUnitConfig.adFormats }
        set { adUnitConfig.adFormats = newValue }
    }
    
    public var additionalSizes: [CGSize]? {
        get { adUnitConfig.additionalSizes }
        set { adUnitConfig.additionalSizes = newValue }
    }
    
    public var skipButtonArea: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonArea }
        set { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonArea = newValue }
    }
    
    public var skipButtonPosition: Position {
        get { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonPosition }
        set { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonPosition = newValue }
    }
    
    public var skipDelay: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.skipDelay }
        set { adUnitConfig.adConfiguration.videoControlsConfig.skipDelay = newValue }
    }
    
    // MARK: - Public Methods
    
    public override convenience init(configId: String, mediationDelegate: PrebidMediationDelegate) {
        self.init(configId: configId, minSizePercentage: nil, mediationDelegate: mediationDelegate)
    }
    
    public init(configId: String, minSizePercentage: CGSize?, mediationDelegate: PrebidMediationDelegate) {
        super.init(configId: configId, mediationDelegate: mediationDelegate)
        
        if let size = minSizePercentage {
            adUnitConfig.minSizePerc = NSValue(cgSize: size)
        }
        
        adUnitConfig.adConfiguration.adFormats = [.display, .video]
    }
    
    // MARK: - Computed Properties
    
    public override var configId: String {
        adUnitConfig.configId
    }
}
