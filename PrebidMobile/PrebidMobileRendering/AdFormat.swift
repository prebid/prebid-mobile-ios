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

/// `AdFormat` is a class that represents different types of ad formats using an OptionSet.
/// The class also includes a deprecated display format for backward compatibility, marked with a deprecation message.
@objcMembers
public class AdFormat: NSObject, OptionSet {
    
    /// The underlying type of the raw value.
    public typealias RawValue = Int
    
    /// The raw integer value representing the ad format.
    public let rawValue: Int
    
    /// The string representation of the ad format.
    public private(set) var stringEquivalent: String?
    
    /// Initializes an `AdFormat` instance with a specified raw value and its string equivalent.
    /// - Parameters:
    ///   - rawValue: The raw value representing the ad format.
    ///   - stringEquivalent: A string equivalent of the ad format.
    public convenience init(rawValue: RawValue, stringEquivalent: String) {
        self.init(rawValue: rawValue)
        self.stringEquivalent = stringEquivalent
    }
    
    /// Initializes an `AdFormat` instance with a specified raw value.
    /// - Parameter rawValue: The raw value representing the ad format.
    public required init(rawValue: RawValue) {
        self.rawValue = rawValue
        super.init()
    }
    
    /// Represents a banner ad format.
    public static let banner = AdFormat(rawValue: 1 << 0, stringEquivalent: "banner")
    
    /// Represents a video ad format.
    public static let video = AdFormat(rawValue: 1 << 1, stringEquivalent: "video")
    
    /// Represents a native ad format.
    public static let native = AdFormat(rawValue: 1 << 2, stringEquivalent: "native")
    
    /// Represents a deprecated display ad format.
    @available(*, deprecated, message: "Display ad format is deprecated. Please, use banner ad format instead.")
    public static let display = AdFormat(rawValue: 1 << 3, stringEquivalent: "banner")
    
    /// An array containing all cases of ad formats, excluding deprecated ones.
    public static var allCases: [AdFormat] {
        [.banner, .video, .native]
    }
}
