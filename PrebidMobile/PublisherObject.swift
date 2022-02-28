/*   Copyright 2018-2021 Prebid.org, Inc.
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

@objc(PBAdUnitPublisherObject)
@objcMembers
public class PublisherObject: NSObject, JSONConvertible, JsonDecodable {
    ///Exchange-specific publisher ID.
    public var id: String?
    ///Publisher name (may be aliased at the publisher’s request).
    public var name: String?
    ///Array of IAB content categories that describe the publisher. Refer to List 5.1.
    public var cat: [String]?
    ///Highest level domain of the publisher (e.g., “publisher.com”).
    public var domain: String?
    ///Placeholder for exchange-specific extensions to OpenRTB.
    public var ext: [String: Any]?
    
    public required init(jsonDictionary: [String : Any]) {
        self.id = jsonDictionary["id"] as? String
        self.name = jsonDictionary["name"] as? String
        self.cat = jsonDictionary["cat"] as? [String]
        self.domain = jsonDictionary["domain"] as? String
        self.ext = jsonDictionary["ext"] as? [String: Any]
    }
    
    public override init() {
        super.init()
    }
    
    func toJSONDictionary() -> [AnyHashable: Any] {
        var publisher = [AnyHashable: Any]()
        
        if let id = id {
            publisher["id"] = id
        }
        
        if let name = name {
            publisher["name"] = name
        }
        
        if let cat = cat {
            publisher["cat"] = cat
        }
        
        if let domain = domain {
            publisher["domain"] = domain
        }
        
        if let ext = ext {
            publisher["ext"] = ext
        }
        
        return publisher
    }
}
