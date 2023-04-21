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

@objcMembers
public class AdFormat: NSObject, OptionSet {
    
    public typealias RawValue = Int
    
    public let rawValue: Int
    
    public private(set) var stringEquivalent: String?
    
    public convenience init(rawValue: RawValue, stringEquivalent: String) {
        self.init(rawValue: rawValue)
        self.stringEquivalent = stringEquivalent
    }
    
    public required init(rawValue: RawValue) {
        self.rawValue = rawValue
        super.init()
    }
        
    public static let banner = AdFormat(rawValue: 1 << 0, stringEquivalent: "banner")
    public static let video = AdFormat(rawValue: 1 << 1, stringEquivalent: "video")
    public static let native = AdFormat(rawValue: 1 << 2, stringEquivalent: "native")
    
    @available(*, deprecated, message: "Display ad format is deprecated. Please, use banner ad format instead.")
    public static let display = AdFormat(rawValue: 1 << 3, stringEquivalent: "banner")
    
    public static var allCases: [AdFormat] {
        [.banner, .video, .native]
    }
}
