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

@objc(PBMVastCreativeNonLinearAdsNonLinear) @_spi(PBMInternal)
public class VastCreativeNonLinearAdsNonLinear: NSObject, VastResourceContainer {

    @objc public var width = 0
    @objc public var height = 0
    @objc public var vastTrackingEvents = VastTrackingEvents()

    @objc public var clickThroughURI: String?
    @objc public var clickTrackingURIs = NSMutableArray()

    @objc public var apiFramework: String?
    @objc(identifier) public var id: String?
    @objc public var scalable = false
    @objc public var maintainAspectRatio = false
    @objc public var minSuggestedDuration: TimeInterval = 0
    @objc public var assetWidth = 0
    @objc public var assetHeight = 0

    // VastResourceContainer
    @objc public var resourceType = VastResourceType.staticResource
    @objc public var resource: String?
    @objc public var staticType: String?

    @objc public override init() { super.init() }
}
