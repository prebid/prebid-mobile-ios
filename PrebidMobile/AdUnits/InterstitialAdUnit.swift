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

/// Represents an interstitial ad unit built for original type of integration.
public class InterstitialAdUnit: AdUnit, BannerBasedAdUnitProtocol, VideoBasedAdUnitProtocol {
    
    /// The deprecated banner parameters for this ad unit.
    @available(*, deprecated, message: "This property is deprecated. Please, use bannerParameters instead.")
    public var parameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
        set { adUnitConfig.adConfiguration.bannerParameters = newValue }
    }
    
    /// The banner parameters for this ad unit.
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
        set { adUnitConfig.adConfiguration.bannerParameters = newValue }
    }
    
    /// The video parameters for this ad unit.
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
        set { adUnitConfig.adConfiguration.videoParameters = newValue }
    }
    
    /// The ad formats for the ad unit.
    public var adFormats: Set<AdFormat> {
        get { adUnitConfig.adFormats }
        set { adUnitConfig.adFormats = newValue }
    }
    
    /// Initializes a new interstitial ad unit with a unique configuration identifier.
    /// - Parameter configId: The unique identifier for the ad unit configuration.
    public init(configId: String) {
        super.init(configId: configId, size: nil, adFormats: [.banner])
        
        adUnitConfig.adConfiguration.isInterstitialAd = true
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.adConfiguration.videoParameters.placement = .Interstitial
        adUnitConfig.adConfiguration.videoParameters.plcmnt = .Interstitial
    }
    
    /// Initializes a new interstitial ad unit with a minimum width and height percentage.
    /// - Parameter configId: The unique identifier for the ad unit configuration.
    /// - Parameter minWidthPerc: The minimum width percentage of the ad.
    /// - Parameter minHeightPerc: The minimum height percentage of the ad.
    public convenience init(configId: String, minWidthPerc: Int, minHeightPerc: Int) {
        self.init(configId: configId)
        
        adUnitConfig.minSizePerc = NSValue(cgSize: CGSize(width: minWidthPerc, height: minHeightPerc))
    }
}
