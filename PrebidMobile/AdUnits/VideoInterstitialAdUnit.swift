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

/// A deprecated class representing a video interstitial ad unit.
/// This class is used to configure and manage video interstitial ads. It inherits from `AdUnit` and provides
/// specific settings for video ads including interstitial ad configuration and placement.
@available(*, deprecated, message: "This class is deprecated. Please, use InterstitialAdUnit with video adFormat.")
public class VideoInterstitialAdUnit: AdUnit {
    
    /// The video parameters for this ad unit.
    /// This property allows you to get or set the video parameters for the ad unit's configuration.
    public var parameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
        set { adUnitConfig.adConfiguration.videoParameters = newValue }
    }

    /// Initializes a new instance of `VideoInterstitialAdUnit` with the specified configuration ID.
    /// The ad unit is configured as an interstitial ad with full screen placement and video parameters set for interstitial ads.
    /// - Parameter configId: The configuration ID for the ad unit.
    public init(configId: String) {
        super.init(configId: configId, size: nil, adFormats: [.video])
        
        adUnitConfig.adConfiguration.isInterstitialAd = true
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.adConfiguration.videoParameters.placement = .Interstitial
        adUnitConfig.adConfiguration.videoParameters.plcmnt = .Interstitial
    }
    
    /// Convenience initializer to create a video interstitial ad unit with specified minimum width and height percentages.
    /// - Parameters:
    ///   - configId: The configuration ID for the ad unit.
    ///   - minWidthPerc: The minimum width percentage of the ad unit.
    ///   - minHeightPerc: The minimum height percentage of the ad unit.
    public convenience init(configId: String, minWidthPerc: Int, minHeightPerc: Int) {
        self.init(configId: configId)
 
        adUnitConfig.minSizePerc = NSValue(cgSize: CGSize(width: minWidthPerc, height: minHeightPerc))
    }
}
