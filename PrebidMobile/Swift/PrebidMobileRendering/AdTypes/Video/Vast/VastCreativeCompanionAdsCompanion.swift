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


class VastCreativeCompanionAdsCompanion: NSObject, VastResourceContainer {

    var width = 0
    var height = 0
    var trackingEvents = VastTrackingEvents()

    var assetWidth = 0
    var assetHeight = 0
    var companionIdentifier: String?
    var clickThroughURI: String?
    var adParameters: String?
    var clickTrackingURIs = NSMutableArray()

    // VastResourceContainer
    var resourceType = VastResourceType.staticResource
    var resource: String?
    var staticType: String?

    override init() { super.init() }
}
