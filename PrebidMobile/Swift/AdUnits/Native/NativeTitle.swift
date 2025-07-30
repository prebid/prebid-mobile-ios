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

/// Represents the title element in a native ad, including optional text and length.
@objcMembers
public class NativeTitle: NSObject, JsonDecodable {
    /// The text associated with the text element.
    public var text: String?
    
    /// The length of the title being provided.
    /// Required if using assetsurl/dcourl representation, optional if using embedded asset representation.
    public var length: Int?
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support
    /// flexibility beyond the standard defined in this specification
    public var ext: [String: Any]?
    
    /// Initializes a `NativeTitle` object from a JSON dictionary.
    ///
    /// - Parameter jsonDictionary: A dictionary containing the JSON representation of the title.
    public required init(jsonDictionary: [String: Any]) {
        guard !jsonDictionary.isEmpty else {
            Log.warn("The native title json dicitonary is empty")
            return
        }
        
        self.text = jsonDictionary["text"] as? String
        self.length = jsonDictionary["len"] as? Int
        self.ext = jsonDictionary["ext"] as? [String: Any]
        
        if text == nil {
            Log.warn("There is no text property in native title response")
        }
    }
    
    /// Initializes a `NativeTitle` object with default values.
    public override init() {
        super.init()
    }
}
