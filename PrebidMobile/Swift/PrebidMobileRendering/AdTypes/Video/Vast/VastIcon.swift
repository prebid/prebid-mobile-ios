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


class VastIcon: NSObject, VastResourceContainer {

    var program = ""
    var width = 0
    var height = 0
    var xPosition = 0
    var yPosition = 0

    var startOffset: TimeInterval = 0
    var duration: TimeInterval = 0

    var clickThroughURI: String?
    var clickTrackingURIs = NSMutableArray()
    var viewTrackingURI: String?

    // computed later
    var displayed = false

    // VastResourceContainer
    var resourceType = VastResourceType.staticResource
    var resource: String?
    var staticType: String?

    override init() { super.init() }
}
