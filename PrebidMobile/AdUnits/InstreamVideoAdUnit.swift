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

/// Represents an instream video ad unit for original type of integration.
public class InstreamVideoAdUnit: AdUnit, VideoBasedAdUnitProtocol {
    
    /// The video parameters for this ad unit.
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
        set { adUnitConfig.adConfiguration.videoParameters = newValue }
    }
    
    /// Initializes a new instream video ad unit.
    /// - Parameter configId: The unique identifier for the ad unit configuration.
    /// - Parameter size: The size of the ad.
    public init(configId: String, size: CGSize) {
        super.init(configId: configId, size: size, adFormats: [.video])
    }
}
