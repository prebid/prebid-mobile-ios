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

@objc(PBAdUnitContentSegmentObject)
@objcMembers
public class ContentSegmentObject: NSObject, JSONConvertible, JsonDecodable {
    ///ID of the data segment specific to the data provider.
    public var id: String?
    ///Name of the data segment specific to the data provider.
    public var name: String?
    ///String representation of the data segment value.
    public var value: String?
    ///Placeholeder to exchange-specific extensions to OpenRTB
    public var ext: [String: Any]?
    
    public required init(jsonDictionary: [String : Any]) {
        self.id = jsonDictionary["id"] as? String
        self.name = jsonDictionary["name"] as? String
        self.value = jsonDictionary["value"] as? String
        self.ext = jsonDictionary["ext"] as? [String: Any]
    }
    
    public override init() {
        super.init()
    }
    
    public func toJSONDictionary() -> [AnyHashable: Any] {
        var segment = [AnyHashable: Any]()
        if let id = id {
            segment["id"] = id
        }
        
        if let name = name {
            segment["name"] = name
        }
        
        if let value = value {
            segment["value"] = value
        }
        
        if let ext = ext, !ext.isEmpty {
            segment["ext"] = ext
        }
        
        return segment
    }
    
    static func ==(lhs: ContentSegmentObject, rhs: ContentSegmentObject) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.value == rhs.value &&
        NSDictionary(dictionary: lhs.ext ?? [:]).isEqual(to: rhs.ext ?? [:])
    }
}
