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

public class NativeAdAsset: NSObject {

    /// [Integer]
    /// Optional if assetsurl/dcourl is being used
    /// Required if embedded asset is being used.
    @objc public var assetID: NSNumber? {
        nativeAdMarkupAsset.assetID
    }
    
    /// [Integer]
    /// Set to 1 if asset is required (bidder requires it to be displayed)
    @objc public var required: NSNumber? {
        nativeAdMarkupAsset.required
    }

    /// Link object for call to actions.
    /// The link object applies if the asset item is activated (clicked).
    /// If there is no link object on the asset, the parent link object on the bid response applies.
    @objc public var link: PBMNativeAdMarkupLink? {
        nativeAdMarkupAsset.link
    }

    /// This object is a placeholder that may contain custom JSON agreed to by the parties to support
    /// flexibility beyond the standard defined in this specification
    @objc public var assetExt: [String : AnyHashable]? {
        nativeAdMarkupAsset.ext as? [String : AnyHashable]
    }
    
    private(set) var nativeAdMarkupAsset: PBMNativeAdMarkupAsset

    @objc public required init(nativeAdMarkupAsset: PBMNativeAdMarkupAsset) throws {
        self.nativeAdMarkupAsset = nativeAdMarkupAsset
    }

    // MARK: - NSCopying
    
    @objc public override func isEqual(_ object: Any?) -> Bool {
        if !(object is Self) {
            return false
        }
        let other = object as? Self
        return self === other || nativeAdMarkupAsset == other?.nativeAdMarkupAsset
    }
    
    // MARK: - Private
    @available(*, unavailable)
    override init() {
        fatalError("Init is unavailable. Use init(nativeAdMarkupAsset:) instead")
    }
}
