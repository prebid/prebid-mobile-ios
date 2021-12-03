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

class PBRNativeEventTracker : NSObject, NSCopying, PBMJsonCodable {
    
    /// [Required]
    /// Type of event available for tracking.
    /// See NativeEventType
    @objc public var event: Int
    
    /// [Required]
    /// Array of the types of tracking available for the given event.
    /// See NativeEventTrackingMethod
    @objc public var methods: [Int]
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
    @objc public var ext: [String : Any]?
    
    // MARK: - Private Properties
    
    @objc public init(event: Int, methods:[Int]) {
        self.event = event
        self.methods = methods
    }
    
    @objc public func setExt(_ ext: [String : Any]?) throws {
        guard let ext = ext else {
            self.ext = nil
            return
        }
        self.ext = try NSDictionary(dictionary: ext).unserializedCopy()
    }
    
    private override init()  {
        fatalError()
    }
    
    // MARK: - NSCopying
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let clone = PBRNativeEventTracker(event: event, methods: methods)
        return clone
    }
    
    // MARK: - PBMJsonCodable
    
    public var jsonDictionary: [String : Any]? {
        var result = [String : Any]()
        result["event"] = event
        result["ext"] = ext
        result["methods"] = methods
        
        return result
    }
    
    public func toJsonString() throws -> String {
        try PBMFunctions.toStringJsonDictionary(jsonDictionary ?? [:])
    }
}
