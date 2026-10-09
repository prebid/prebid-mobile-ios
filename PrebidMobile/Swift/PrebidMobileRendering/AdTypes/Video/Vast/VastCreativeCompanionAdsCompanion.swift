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

@objc(PBMVastCreativeCompanionAdsCompanion) @_spi(PBMInternal)
public class VastCreativeCompanionAdsCompanion: NSObject, VastResourceContainer {

    @objc public var width = 0
    @objc public var height = 0
    @objc public var trackingEvents = VastTrackingEvents()

    @objc public var assetWidth = 0
    @objc public var assetHeight = 0
    @objc public var companionIdentifier: String?
    @objc public var clickThroughURI: String?
    @objc public var adParameters: String?
    @objc public var clickTrackingURIs = NSMutableArray()

    // VastResourceContainer
    @objc public var resourceType = VastResourceType.staticResource
    @objc public var resource: String?
    @objc public var staticType: String?

    @objc public override init() { super.init() }
}
