/*   Copyright 2018-2019 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import MapKit

private let swizzling: (AnyClass, Selector, Selector) -> Void = { forClass, originalSelector, swizzledSelector in
    if let originalMethod = class_getInstanceMethod(forClass, originalSelector),
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector) {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension CLLocationManager {
    static let classInit: Void = {
        let originalSelector = #selector(CLLocationManager.startUpdatingLocation)
        let swizzledSelector = #selector(swizzledStartLocation)
        swizzling(CLLocationManager.self, originalSelector, swizzledSelector)

        let originalStopSelector = #selector(CLLocationManager.stopUpdatingLocation)
        let swizzledStopSelector = #selector(swizzledStopLocation)
        swizzling(CLLocationManager.self, originalStopSelector, swizzledStopSelector)
    }()

    @objc func swizzledStartLocation() {
        print("swizzled start location")
        if !MockCLLocationManager.shared.isRunning {
            MockCLLocationManager.shared.startMocks(usingGpx: "locationTrack")
        }
        MockCLLocationManager.shared.delegate = self.delegate
        MockCLLocationManager.shared.startUpdatingLocation()
    }

    @objc func swizzledStopLocation() {
        print("swizzled stop location")
        MockCLLocationManager.shared.stopUpdatingLocation()
    }

    @objc func swizzedRequestLocation() {
        print("swizzled request location")
        MockCLLocationManager.shared.requestLocation()
    }
}
