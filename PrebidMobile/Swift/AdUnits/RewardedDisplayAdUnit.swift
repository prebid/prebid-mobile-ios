/*   Copyright 2026 Prebid.org, Inc.

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

/// Represents a rewarded display ad unit for original type of integration.
@objcMembers
public class RewardedDisplayAdUnit: InterstitialAdUnit {
    
    /// Initializes a `RewardedDisplayAdUnit` with the given configuration ID.
    ///
    /// - Parameter configId: The configuration ID for the ad unit.
    public override init(configId: String) {
        super.init(configId: configId)
        adUnitConfig.adConfiguration.isRewarded = true
    }
    
    /// Initializes a `RewardedDisplayAdUnit` with the given configuration ID and minimum size percentages.
    ///
    /// - Parameter configId: The configuration ID for the ad unit.
    /// - Parameter minWidthPerc: The minimum width percentage for the ad unit.
    /// - Parameter minHeightPerc: The minimum height percentage for the ad unit.
    public convenience init(configId: String, minWidthPerc: Int, minHeightPerc: Int) {
        self.init(configId: configId)
        adUnitConfig.minSizePerc = NSValue(cgSize: CGSize(width: minWidthPerc, height: minHeightPerc))
    }
}
