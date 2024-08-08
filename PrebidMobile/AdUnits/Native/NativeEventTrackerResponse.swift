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

/// Class representing a response for a native event tracker.
@objcMembers
public class NativeEventTrackerResponse: NSObject, JsonDecodable {
    
    /// Type of event to track.
    /// See Event Types table.
    public var event: Int?
    
    /// Type of tracking requested.
    /// See Event Tracking Methods table.
    public var method: Int?
    
    /// The URL of the image or js.
    /// Required for image or js, optional for custom.
    public var url: String?
    
    /// To be agreed individually with the exchange, an array of key:value objects for custom tracking,
    /// for example the account number of the DSP with a tracking company. IE {“accountnumber”:”123”}.
    public var customdata: [String: Any]?
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
    public var ext: [String: Any]?
    
    /// Initializes a `NativeEventTrackerResponse` object from a JSON dictionary.
    ///
    /// - Parameter jsonDictionary: A dictionary containing the JSON data to initialize the object.
    public required init(jsonDictionary: [String: Any]) {
        guard !jsonDictionary.isEmpty else {
            Log.warn("The native event trackers json dicitonary is empty")
            return
        }
        
        self.event = jsonDictionary["event"] as? Int
        self.method = jsonDictionary["method"] as? Int
        self.url = jsonDictionary["url"] as? String
        self.customdata = jsonDictionary["customdata"] as? [String: Any]
        self.ext = jsonDictionary["ext"] as? [String: Any]
        
        if event == nil {
            Log.warn("There is no event property in native event tracker response")
        }
        
        if method == nil {
            Log.warn("There is no method property in native event tracker response")
        }
        
        if url == nil {
            Log.warn("There is no url property in native event tracker response")
        }
    }
    
    /// Initializes with default values
    public override init() {
        super.init()
    }
}
