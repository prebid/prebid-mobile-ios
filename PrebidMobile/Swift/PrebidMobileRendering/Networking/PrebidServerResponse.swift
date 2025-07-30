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
public class PrebidServerResponse: NSObject {
    
    public var isOKStatusCode: Bool {
        return (200...299).contains(statusCode)
    }
    
    public var jsonDict: [String: Any]?
    public var rawData: Data?
    public var requestHeaders: [String: String]?
    public var responseHeaders: [String: String]?
    public var requestURL: String?
    public var error: Error?
    public var statusCode = 0
}
