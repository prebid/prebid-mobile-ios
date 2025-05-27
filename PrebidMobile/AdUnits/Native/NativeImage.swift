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

/// Class representing an image asset in a native ad.
@objcMembers
public class NativeImage: NSObject, JsonDecodable {
    
    /// The type of image element being submitted from the Image Asset Types table.
    /// Required for assetsurl or dcourl responses, not required for embedded asset responses.
    public var type: Int?
    
    /// URL of the image asset.
    public var url: String?
    
    /// Width of the image in pixels.
    /// Recommended for embedded asset responses.
    /// Required for assetsurl/dcourlresponses if multiple assets of same type submitted.
    public var width: Int?

    /// Height of the image in pixels.
    /// Recommended for embedded asset responses.
    /// Required for assetsurl/dcourl responses if multiple assets of same type submitted.
    public var height: Int?
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support
    /// flexibility beyond the standard defined in this specification
    public var ext: [String: Any]?
    
    /// Initializes a `NativeImage` object from a JSON dictionary.
    ///
    /// - Parameter jsonDictionary: A dictionary containing the JSON data to initialize the object.
    public required init(jsonDictionary: [String: Any]) {
        guard !jsonDictionary.isEmpty else {
            Log.warn("The native image json dicitonary is empty")
            return
        }
        
        self.type = jsonDictionary["type"] as? Int
        self.url = jsonDictionary["url"] as? String
        self.width = jsonDictionary["w"] as? Int
        self.height = jsonDictionary["h"] as? Int
        self.ext = jsonDictionary["ext"] as? [String: Any]
        
        if url == nil {
            Log.warn("There is no url in native image response")
        }
    }
    
    /// Initializes with default values
    public override init() {
        super.init()
    }
}
