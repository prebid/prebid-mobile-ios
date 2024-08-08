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

/// A deprecated class for handling video ad units.
@available(*, deprecated, message: "This class is deprecated. Please, use BannerAdUnit with video adFormat.")
public class VideoAdUnit: AdUnit {
    
    /// The parameters for video ads associated with this ad unit.
    public var parameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
        set { adUnitConfig.adConfiguration.videoParameters = newValue }
    }
    
    /// Initializes a new instance of `VideoAdUnit` with the specified configuration ID and size.
    ///
    /// - Parameters:
    ///   - configId: The configuration ID for the ad unit.
    ///   - size: The size of the ad unit.
    public init(configId: String, size: CGSize) {
        super.init(configId: configId, size: size, adFormats: [.video])
    }
    
    /// Adds additional sizes to the ad unit.
    ///
    /// - Parameter sizes: An array of `CGSize` objects representing the additional sizes for the ad unit.
    public func addAdditionalSize(sizes: [CGSize]) {
        if super.adUnitConfig.additionalSizes == nil {
            super.adUnitConfig.additionalSizes = [CGSize]()
        }
        
        super.adUnitConfig.additionalSizes?.append(contentsOf: sizes)
    }
}
