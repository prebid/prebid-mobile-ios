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

/// This class is responsible for making bid request and providing the winning bid and targeting keywords to mediating SDKs.
/// This class is a part of Mediation API.
@objcMembers
public class MediationInterstitialAdUnit: MediationBaseInterstitialAdUnit {
    
    // MARK: - Public Properties
    
    /// The ad format for the ad unit.
    public var adFormats: Set<AdFormat> {
        get { adUnitConfig.adFormats }
        set { adUnitConfig.adFormats = newValue }
    }
    
    /// Additional sizes for the ad unit.
    public var additionalSizes: [CGSize]? {
        get { adUnitConfig.additionalSizes }
        set { adUnitConfig.additionalSizes = newValue }
    }
    
    /// The area for the skip button in the video ad.
    public var skipButtonArea: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonArea }
        set { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonArea = newValue }
    }
    
    /// The position of the skip button in the video ad.
    public var skipButtonPosition: Position {
        get { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonPosition }
        set { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonPosition = newValue }
    }
    
    /// The delay before the skip button appears in the video ad.
    public var skipDelay: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.skipDelay }
        set { adUnitConfig.adConfiguration.videoControlsConfig.skipDelay = newValue }
    }
    
    // MARK: - Public Methods
    
    /// Convenience initializer for the mediation interstitial ad unit.
    /// - Parameters:
    ///   - configId: The unique identifier for the ad unit configuration.
    ///   - mediationDelegate: The delegate for handling mediation.
    public override convenience init(configId: String, mediationDelegate: PrebidMediationDelegate) {
        self.init(configId: configId, minSizePercentage: nil, mediationDelegate: mediationDelegate)
    }
    
    /// Initializes a new mediation interstitial ad unit with the specified configuration ID, minimum size percentage, and mediation delegate.
    /// - Parameters:
    ///   - configId: The unique identifier for the ad unit configuration.
    ///   - minSizePercentage: The minimum size percentage for the ad.
    ///   - mediationDelegate: The delegate for handling mediation.
    public init(configId: String, minSizePercentage: CGSize?, mediationDelegate: PrebidMediationDelegate) {
        super.init(configId: configId, mediationDelegate: mediationDelegate)
        
        if let size = minSizePercentage {
            adUnitConfig.minSizePerc = NSValue(cgSize: size)
        }
    }
    
    // MARK: - Computed Properties
    
    /// The configuration ID for the ad unit.
    public override var configId: String {
        adUnitConfig.configId
    }
}
