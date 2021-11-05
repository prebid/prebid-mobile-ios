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
import PrebidMobile

extension Array where Self.Element == NativeAsset {
    static let defaultNativeRequestAssets: [NativeAsset] = [
        {
            let title = NativeAssetTitle(length: 90)
            title.required = true
            return title
        }(),
        {
            let icon = NativeAssetImage()
            icon.widthMin = 50
            icon.heightMin = 50
            icon.required = 1
            icon.imageType = NSNumber(value: NativeImageAssetType.icon.rawValue)
            return icon
        }(),
        {
            let image = NativeAssetImage()
            image.widthMin = 150
            image.heightMin = 50
            image.required = 1
            image.imageType = NSNumber(value: NativeImageAssetType.main.rawValue)
            return image
        }(),
        {
            let desc = NativeAssetData(dataType: .desc)
            desc.required = 1
            return desc
        }(),
        {
            let cta = NativeAssetData(dataType: .ctaText)
            cta.required = 1
            return cta
        }(),
        {
            let sponsored = NativeAssetData(dataType: .sponsored)
            sponsored.required = 1
            return sponsored
        }(),
    ]
}

// TODO: additional parameters for trackers, context, etc. (?)
extension NativeAdConfiguration {
    convenience init(testConfigWithAssets assets: [NativeAsset]) {
        self.init(assets: assets)
        
        self.eventtrackers = [
            NativeEventTracker(event: NativeEventType.impression.rawValue,
                                  methods: [
                                    NativeEventTrackingMethod.img,
                                    .js,
                                  ].map { $0.rawValue }),
        ]
        
        self.context = NativeContextType.socialCentric.rawValue
        self.contextsubtype = NativeContextSubtype.social.rawValue
        self.plcmttype = NativePlacementType.feedGridListing.rawValue
    }
}
