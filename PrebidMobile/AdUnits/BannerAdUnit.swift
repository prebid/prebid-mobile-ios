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

/// A class representing a banner ad unit for original type of integration.
public class BannerAdUnit: AdUnit, BannerBasedAdUnitProtocol, VideoBasedAdUnitProtocol {
    
    /// A deprecated property for banner ad parameters.
    @available(*, deprecated, message: "This property is deprecated. Please, use bannerParameters instead.")
    public var parameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
        set { adUnitConfig.adConfiguration.bannerParameters = newValue }
    }
    
    /// The banner ad parameters used to configure the ad unit.
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
        set { adUnitConfig.adConfiguration.bannerParameters = newValue }
    }
    
    /// The video ad parameters used to configure the ad unit.
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
        set { adUnitConfig.adConfiguration.videoParameters = newValue }
    }
    
    /// The set of ad formats for the ad unit.
    public var adFormats: Set<AdFormat> {
        get { adUnitConfig.adFormats }
        set { adUnitConfig.adFormats = newValue }
    }
    
    /// Initializes a new `BannerAdUnit` with the specified configuration ID and size.
    /// - Parameters:
    ///   - configId: The unique identifier for the ad unit configuration.
    ///   - size: The size of the banner ad unit.
    public init(configId: String, size: CGSize) {
        super.init(configId: configId, size: size, adFormats: [.banner])
    }

    /// Adds additional sizes to the banner ad unit's configuration.
    /// - Parameter sizes: An array of `CGSize` objects representing additional sizes.
    public func addAdditionalSize(sizes: [CGSize]) {
        if super.adUnitConfig.additionalSizes == nil {
            super.adUnitConfig.additionalSizes = [CGSize]()
        }
        
        super.adUnitConfig.additionalSizes?.append(contentsOf: sizes)
    }
}
