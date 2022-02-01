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
public class NativeAdMarkupAsset: NSObject, PBMJsonDecodable {
    
    /// Optional if asseturl/dcourl is being used; required if embeded asset is being used
    public var id: Int?
    
    /// Set to 1 if asset is required. (bidder requires it to be displayed).
    public var required: Int?
    
    /// Link object for call to actions.
    /// The link object applies if the asset item is activated (clicked).
    /// If there is no link object on the asset, the parent link object on the bid response applies.
    public var link: NativeLink?
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support
    /// flexibility beyond the standard defined in this specification
    public var ext: [String: Any]?
    
    public required init(jsonDictionary: [String: Any]) throws {
        guard !jsonDictionary.isEmpty else {
            PBMLog.warn("The native title json dicitonary is empty")
            return
        }
        
        self.id = jsonDictionary["id"] as? Int
        self.required = jsonDictionary["required"] as? Int
        self.ext = jsonDictionary["ext"] as? [String: Any]
        
        if let linkDictionary = jsonDictionary["link"] as? [String: Any] {
            self.link = try NativeLink(jsonDictionary: linkDictionary)
        }
    }
}
