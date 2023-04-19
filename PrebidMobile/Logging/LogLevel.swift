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

@objc(PBMLogLevel) @objcMembers
public class LogLevel: NSObject, RawRepresentable {
    
    public typealias RawValue = Int
  
    public var rawValue: Int
    
    public var stringValue = ""
    
    public convenience init(stringValue: String, rawValue: RawValue) {
        self.init(rawValue: rawValue)
        self.stringValue = stringValue
    }
    
    public required init(rawValue: RawValue) {
        self.rawValue = rawValue
        super.init()
    }
    
    public static let debug = LogLevel(stringValue: "[💬]", rawValue: 0)
    public static let verbose = LogLevel(stringValue: "[🔬]", rawValue: 1)
    public static let info = LogLevel(stringValue: "[ℹ️]", rawValue: 2)
    public static let warn = LogLevel(stringValue: "[⚠️]", rawValue: 3)
    public static let error = LogLevel(stringValue: "[‼️]", rawValue: 4)
    public static let severe = LogLevel(stringValue: "[🔥]", rawValue: 5)
}
