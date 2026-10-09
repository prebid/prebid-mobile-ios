//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

@objc(PBMVastCreativeLinear)
@_spi(PBMInternal) public class VastCreativeLinear: VastCreativeAbstract {

    // Untyped `NSMutableArray` (not a Swift array): surviving ObjC parser code appends in place.
    // Elements are `VastIcon`.
    @objc public var icons = NSMutableArray()
    @objc public var skipOffset: NSNumber?
    @objc public var duration: TimeInterval = 0
    // Elements are `VastMediaFile`.
    @objc public var mediaFiles = NSMutableArray()
    @objc public var vastTrackingEvents = VastTrackingEvents()

    @objc public var clickThroughURI: String?
    @objc public var clickTrackingURIs = NSMutableArray()

    @objc public override init() {
        super.init()
    }

    @objc public func bestMediaFile() -> VastMediaFile? {
        let eligibleMediaFiles = mediaFiles.compactMap { $0 as? VastMediaFile }.filter {
            PrebidConstants.SUPPORTED_VIDEO_MIME_TYPES.contains($0.type)
        }

        // choose the one with the highest resolution that is acceptable
        guard var bestMediaFile = eligibleMediaFiles.first else {
            return nil
        }
        for mediaFile in eligibleMediaFiles where mediaFile.width * mediaFile.height > bestMediaFile.width * bestMediaFile.height {
            bestMediaFile = mediaFile
        }
        return bestMediaFile
    }
}
