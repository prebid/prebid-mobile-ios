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

/// Represents an asset in the native ad markup, which can be a title, image, data, or link.
@objcMembers
public class NativeAdMarkupAsset: NSObject, JsonDecodable {
    
    /// Optional if asseturl/dcourl is being used; required if embeded asset is being used
    public var id: Int?
    
    /// Set to 1 if asset is required. (bidder requires it to be displayed).
    public var required: Int?
    
    /// Title object for title assets.
    /// See TitleObject definition.
    public var title: NativeTitle?
    
    /// Image object for image assets.
    /// See ImageObject definition.
    public var img: NativeImage?
    
    /// Data object for ratings, prices etc.
    public var data: NativeData?
    
    /// Link object for call to actions.
    /// The link object applies if the asset item is activated (clicked).
    /// If there is no link object on the asset, the parent link object on the bid response applies.
    public var link: NativeLink?
    
    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support
    /// flexibility beyond the standard defined in this specification
    public var ext: [String: Any]?
    
    /// Initializes a new instance of `NativeAdMarkupAsset` from a JSON dictionary.
    /// - Parameter jsonDictionary: A dictionary representing the asset in the native ad markup.
    public required init(jsonDictionary: [String: Any]) {
        guard !jsonDictionary.isEmpty else {
            Log.warn("The native title json dicitonary is empty")
            return
        }
        
        self.id = jsonDictionary["id"] as? Int
        self.required = jsonDictionary["required"] as? Int
        self.ext = jsonDictionary["ext"] as? [String: Any]
        
        if let titleDictionary = jsonDictionary["title"] as? [String: Any] {
            self.title = NativeTitle(jsonDictionary: titleDictionary)
        } else if let imgDictionary = jsonDictionary["img"] as? [String: Any] {
            self.img = NativeImage(jsonDictionary: imgDictionary)
        } else if let dataDictionary = jsonDictionary["data"] as? [String: Any] {
            self.data = NativeData(jsonDictionary: dataDictionary)
        }
        
        if let linkDictionary = jsonDictionary["link"] as? [String: Any] {
            self.link = NativeLink(jsonDictionary: linkDictionary)
        }
    }
    
    /// Initializes a new instance of `NativeAdMarkupAsset` with default values.
    public override init() {
        super.init()
    }
}
