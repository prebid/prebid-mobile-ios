/*   Copyright 2018-2019 Prebid.org, Inc.

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

/// Represents an rewarded ad unit for original type of integration.
public class RewardedVideoAdUnit: AdUnit, VideoBasedAdUnitProtocol {
    
    /// Deprecated property for video parameters.
    ///
    /// - Note: This property is deprecated. Please use `videoParameters` instead.
    @available(*, deprecated, message: "This property is deprecated. Please, use videoParameters instead.")
    public var parameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
        set { adUnitConfig.adConfiguration.videoParameters = newValue }
    }
    
    /// Property for video parameters.
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
        set { adUnitConfig.adConfiguration.videoParameters = newValue }
    }

    /// Initializes a `RewardedVideoAdUnit` with the given configuration ID.
    ///
    /// - Parameter configId: The configuration ID for the ad unit.
    public init(configId: String) {
        super.init(configId: configId, size: nil, adFormats: [.video])
        adUnitConfig.adConfiguration.isInterstitialAd = true
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.adConfiguration.videoParameters.placement = .Interstitial
        adUnitConfig.adConfiguration.videoParameters.plcmnt = .Interstitial
    }
    
    /// Initializes a `RewardedVideoAdUnit` with the given configuration ID and minimum size percentages.
    ///
    /// - Parameter configId: The configuration ID for the ad unit.
    /// - Parameter minWidthPerc: The minimum width percentage for the ad unit.
    /// - Parameter minHeightPerc: The minimum height percentage for the ad unit.
    public convenience init(configId: String, minWidthPerc: Int, minHeightPerc: Int) {
        self.init(configId: configId)
        adUnitConfig.minSizePerc = NSValue(cgSize: CGSize(width: minWidthPerc, height: minHeightPerc))
    }
}
