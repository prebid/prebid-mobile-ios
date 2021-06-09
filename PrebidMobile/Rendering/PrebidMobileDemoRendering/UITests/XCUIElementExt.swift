/*   Copyright 2018-2021 Prebid.org, Inc.

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

//  sourced from
//  https://stackoverflow.com/questions/41353959/xctest-how-to-tap-on-url-link-inside-uitextview

import XCTest

extension XCUIElement {
    
    public func tapFrameCenter(withNumberOfTaps numberOfTaps: Int = 1) {
        let frameCenterCoordinate = self.frameCenter()
        for _ in 0..<numberOfTaps {
            frameCenterCoordinate.tap()
        }
    }

    func frameCenter() -> XCUICoordinate {
        let centerX = self.frame.midX
        let centerY = self.frame.midY

        let normalizedCoordinate = XCUIApplication().coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let frameCenterCoordinate = normalizedCoordinate.withOffset(CGVector(dx: centerX, dy: centerY))

        return frameCenterCoordinate
    }
    
    var isOn: Bool {
        return (value as? String).map { $0 == "1" } ?? false
    }
}
