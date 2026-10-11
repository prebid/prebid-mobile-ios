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

@objc(PBMVastMediaFile) @_spi(PBMInternal)
public class VastMediaFile: NSObject {

    @objc public var streamingDeliver = false
    @objc public var type = ""
    @objc public var width = 0
    @objc public var height = 0
    @objc public var mediaURI = ""

    @objc public var id: String?
    @objc public var codec: String?
    @objc public var deivery: String?
    @objc public var bitrate: NSNumber?
    @objc public var minBitrate: NSNumber?
    @objc public var maxBitrate: NSNumber?
    @objc public var scalable: NSNumber?
    @objc public var maintainAspectRatio: NSNumber?
    @objc public var apiFramework: String?

    @objc public override init() { super.init() }

    @objc(setDeliver:)
    public func setDeliver(_ deliveryMode: String?) {
        streamingDeliver = deliveryMode == "streaming"
    }
}
