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

@objc(PBMVastAbstractAd)
@_spi(PBMInternal) public class VastAbstractAd: NSObject {

    @objc public weak var ownerResponse: VastResponse?

    @objc public var identifier = ""
    @objc public var sequence = 0
    @objc public var adSystem = ""
    @objc public var adSystemVersion = ""

    // Untyped `NSMutableArray` (not `[String]`): surviving ObjC code appends in place, which a
    // Swift value-type array bridged through a getter would not support.
    @objc public var impressionURIs = NSMutableArray()
    @objc public var errorURIs = NSMutableArray()

    // Elements are `VastCreativeAbstract`; untyped for the same reason as above.
    @objc public var creatives = NSMutableArray()

    @objc public override init() {
        super.init()
    }
}
