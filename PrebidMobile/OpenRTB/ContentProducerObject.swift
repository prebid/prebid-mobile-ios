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
public class ContentProducerObject: NSObject, JSONConvertible {
    ///Content producer or originator ID.
    public var id: String?
    ///Content producer or originator name (e.g., “Warner Bros”).
    public var name: String?
    ///Array of IAB content categories that describe the content producer.
    public var cat: [String]?
    ///Highest level domain of the content producer (e.g., “producer.com”).
    public var domain: String?
    ///Placeholeder to exchange-specific extensions to OpenRTB
    public var ext: [String: Any]?
    
    public func toJSONDictionary() -> [AnyHashable: Any] {
        var producer = [AnyHashable: Any]()
        
        if let id = id {
            producer["id"] = id
        }
        
        if let name = name {
            producer["name"] = name
        }
        
        if let cat = cat {
            producer["cat"] = cat
        }
        
        if let domain = domain {
            producer["domain"] = domain
        }
        
        if let ext = ext, !ext.isEmpty {
            producer["ext"] = ext
        }
        
        return producer
    }
}
