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

@objc enum AdRefreshType: UInt {
    /// Do Not Refresh (autoRefreshDelay is nil or negative)
    case stopWithRefreshDelay = 1

    /// AutoRefreshMax has been reached
    case stopWithRefreshMax

    /// Reload after given delay
    case reloadLater
}

@objc class AdRefreshOptions: NSObject {

    let type: AdRefreshType
    let delay: Double

    @objc(initWithType:delay:)
    init(type: AdRefreshType, delay: Double) {
        self.type = type
        self.delay = delay
        super.init()
    }

    @available(*, unavailable, message: "Use init(type:delay:) instead")
    override init() {
        fatalError("init() has been marked unavailable. Use init(type:delay:) instead.")
    }
}
