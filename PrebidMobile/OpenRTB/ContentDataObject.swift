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
public class ContentDataObject: NSObject, JSONConvertible {
    ///Exchange-specific ID for the data provider.
    public var id: String?
    ///Exchange-specific name for the data provider.
    public var name: String?
    ///Segment objects are essentially key-value pairs that convey specific units of data.
    public var segment: [ContentSegmentObject]?
    
    public func toJSONDictionary() -> [AnyHashable: Any] {
        var data = [AnyHashable: Any]()
        if let id = id {
            data["id"] = id
        }
        
        if let name = name {
            data["name"] = name
        }
        
        if let segment = segment {
            var segmentArray: [[AnyHashable: Any]] = []
            
            segment.forEach({
                segmentArray += [$0.toJSONDictionary()]
            })
            
            data["segment"] = segmentArray
        }
        return data
    }
}
