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

/// Class representing a  link in a native ad.
@objcMembers
public class NativeLink: NSObject, JsonDecodable {
    
    /// Landing URL of the clickable link.
    public var url: String?
    
    /// List of third-party tracker URLs to be fired on click of the URL.
    public var clicktrackers: [String]?
    
    /// Fallback URL for deeplink.
    /// To be used if the URL given in url is not supported by the device.
    public var fallback: String?
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support flexibility beyond the standard defined in this specification
    public var ext: [String: Any]?
    
    /// Initializes a `NativeLink` object from a JSON dictionary.
    ///
    /// - Parameter jsonDictionary: A dictionary containing the JSON data to initialize the object.
    public required init(jsonDictionary: [String: Any]) {
        guard !jsonDictionary.isEmpty else {
            Log.warn("The native link json dicitonary is empty")
            return
        }
        
        self.url = jsonDictionary["url"] as? String
        self.clicktrackers = jsonDictionary["clicktrackers"] as? [String]
        self.fallback = jsonDictionary["fallback"] as? String
        self.ext = jsonDictionary["ext"] as? [String: Any]
        
        if url == nil {
            Log.warn("There is no url property in native link response")
        }
    }

    /// Initializes with default values
    public override init() {
        super.init()
    }
}
