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

/// Enum representing various types of native image assets used in ads.
///
/// Each case corresponds to a different type of image asset that can be used in native ads.
/// Values are defined according to the role or importance of the image in the ad.
@objc public enum NativeImageAssetType: Int {
    
    /// Represents an icon image, which is typically a small image used as a visual representation of the product or service.
    case icon = 1
    
    /// Represents the main image of the ad, which is usually the primary visual element and central to the ad's presentation.
    case main = 3
    
    /// Reserved for exchange-specific usage.
    case custom = 500
}
