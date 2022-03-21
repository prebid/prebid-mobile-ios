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
public class LogLevel: NSObject, OptionSet {
    
    public typealias RawValue = Int
        
    public let rawValue: Int
    public var stringValue = ""
    
    public convenience init(rawValue: RawValue, stringValue: String) {
        self.init(rawValue: rawValue)
        self.stringValue = stringValue
    }
    
    public required init(rawValue: RawValue) {
        self.rawValue = rawValue
        super.init()
    }
    
    public static let debug = LogLevel(rawValue: 1 << 0, stringValue: "[💬]")
    public static let verbose = LogLevel(rawValue: 1 << 1, stringValue: "[🔬]")
    public static let info = LogLevel(rawValue: 1 << 2, stringValue: "[ℹ️]")
    public static let warn = LogLevel(rawValue: 1 << 3, stringValue: "[⚠️]")
    public static let error = LogLevel(rawValue: 1 << 4, stringValue: "[‼️]")
    public static let severe = LogLevel(rawValue: 1 << 5, stringValue: "[🔥]")
}
