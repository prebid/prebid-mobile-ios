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
import UIKit

@_spi(PBMInternal) public
typealias ViewExposureChangeHandler = (_ tracker: CreativeViewabilityTracker, _ viewExposure: ViewExposure) -> Void

@objc(PBMCreativeViewabilityTracker)
@_spi(PBMInternal) public
protocol CreativeViewabilityTracker: NSObjectProtocol {
    
    init(view: UIView, pollingTimeInterval: TimeInterval, onExposureChange: @escaping ViewExposureChangeHandler)
    init(creative: AbstractCreative)
    
    func start()
    func stop()
    
    /**
     Checks the current exposure.
     The onExposureChange will be called either exposure changed or isForce is true
     */
    func checkExposure(force: Bool)
    
#if DEBUG
    // Expose for tests
    func checkViewability()
#endif
    
}
