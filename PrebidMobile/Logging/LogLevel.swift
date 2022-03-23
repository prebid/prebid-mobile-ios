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
public class LogLevel: NSObject {
    
    public var stringValue = ""
    
    public required init(stringValue: String) {
        self.stringValue = stringValue
        super.init()
    }
    
    public static let debug = LogLevel(stringValue: "[💬]")
    public static let verbose = LogLevel(stringValue: "[🔬]")
    public static let info = LogLevel(stringValue: "[ℹ️]")
    public static let warn = LogLevel(stringValue: "[⚠️]")
    public static let error = LogLevel(stringValue: "[‼️]")
    public static let severe = LogLevel(stringValue: "[🔥]")
}
