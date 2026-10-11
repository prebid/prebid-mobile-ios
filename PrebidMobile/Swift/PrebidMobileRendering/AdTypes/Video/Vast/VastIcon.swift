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

@objc(PBMVastIcon) @_spi(PBMInternal)
public class VastIcon: NSObject, VastResourceContainer {

    @objc public var program = ""
    @objc public var width = 0
    @objc public var height = 0
    @objc public var xPosition = 0
    @objc public var yPosition = 0

    @objc public var startOffset: TimeInterval = 0
    @objc public var duration: TimeInterval = 0

    @objc public var clickThroughURI: String?
    @objc public var clickTrackingURIs = NSMutableArray()
    @objc public var viewTrackingURI: String?

    // computed later
    @objc public var displayed = false

    // VastResourceContainer
    @objc public var resourceType = VastResourceType.staticResource
    @objc public var resource: String?
    @objc public var staticType: String?

    @objc public override init() { super.init() }
}
