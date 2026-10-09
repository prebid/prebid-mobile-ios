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

@objc(PBMVastWrapperAd)
@_spi(PBMInternal) public class VastWrapperAd: VastAbstractAd {

    /// The location of the next VAST tag.
    @objc public var vastURI: String?

    // Typed `AnyObject?` because `PBMVastResponse` is still Objective-C and not visible to Swift.
    @objc public var vastResponse: AnyObject?

    @objc public var depth = 0
    @objc public var followAdditionalWrappers = true
    @objc public var allowMultipleAds = false
    @objc public var fallbackOnNoAd = false

    @objc public override init() {
        super.init()
    }
}
