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


class VastMediaFile: NSObject {

    var streamingDeliver = false
    var type = ""
    var width = 0
    var height = 0
    var mediaURI = ""

    var id: String?
    var codec: String?
    var deivery: String?
    var bitrate: NSNumber?
    var minBitrate: NSNumber?
    var maxBitrate: NSNumber?
    var scalable: NSNumber?
    var maintainAspectRatio: NSNumber?
    var apiFramework: String?

    override init() { super.init() }
    func setDeliver(_ deliveryMode: String?) {
        streamingDeliver = deliveryMode == "streaming"
    }
}
