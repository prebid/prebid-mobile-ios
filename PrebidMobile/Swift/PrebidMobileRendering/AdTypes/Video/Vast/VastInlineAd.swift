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


class VastInlineAd: VastAbstractAd {

    var title: String?
    var advertiser: String?
    var verificationParameters = VideoVerificationParameters()
    override init() {
        super.init()
    }

    // The first Linear creative that has a media file the SDK can play, or nil if there is none.
    // VAST validation and creative model creation both select the creative through this method.
    func playableLinearCreative() -> VastCreativeLinear? {
        for case let linearCreative as VastCreativeLinear in creatives where linearCreative.bestMediaFile() != nil {
            return linearCreative
        }
        return nil
    }
}
