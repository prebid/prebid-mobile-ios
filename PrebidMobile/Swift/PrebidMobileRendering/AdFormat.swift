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
    
    /// An array containing all cases of ad formats.
    public static var allCases: [AdFormat] {
        [.banner, .video, .native]
    }
}

// MARK: - Internal helpers

extension AdFormat {
    
    /// Validates a publisher-provided set of formats against the formats an ad unit can render.
    ///
    /// Returns `formats` when it is non-empty and every element is in `supported`.
    /// Otherwise logs a warning and returns `nil`, so the caller keeps its current value.
    /// - Parameters:
    ///   - formats: The requested set of ad formats.
    ///   - supported: The formats the calling ad unit is able to render.
    static func validated(_ formats: Set<AdFormat>, supported: [AdFormat]) -> Set<AdFormat>? {
        guard formats.isEmpty == false else {
            Log.warn("Attempted to set empty adFormats. The current value is kept.")
            return nil
        }
        
        let unsupported = formats.filter { !supported.contains($0) }
        guard unsupported.isEmpty else {
            Log.warn("Unsupported ad formats: [\(unsupported.formatNames)]. Only [\(supported.formatNames)] are supported. The current value is kept.")
            return nil
        }
        
        return formats
    }
}

extension Sequence where Element == AdFormat {
    
    /// Comma-separated, sorted, human-readable names for logging (e.g. `banner, video`).
    var formatNames: String {
        map { $0.stringEquivalent ?? String($0.rawValue) }
            .sorted()
            .joined(separator: ", ")
    }
}
