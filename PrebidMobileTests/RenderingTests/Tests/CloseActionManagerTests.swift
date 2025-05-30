/*   Copyright 2018-2023 Prebid.org, Inc.
 
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

import XCTest
@testable import PrebidMobile

class CloseActionManagerTests: XCTestCase {

    func testGetActionWithCloseButtonDescription() {
        let action = CloseActionManager.getAction(from: "closebutton")
        XCTAssertEqual(action.rawValue, CloseAction.closeButton.rawValue)
    }

    func testGetActionWithAutoCloseDescription() {
        let action = CloseActionManager.getAction(from: "autoclose")
        XCTAssertEqual(action.rawValue, CloseAction.autoClose.rawValue)
    }

    func testGetActionWithUnknownDescription() {
        let action = CloseActionManager.getAction(from: "unknown")
        XCTAssertEqual(action.rawValue, CloseAction.unknown.rawValue)
    }

    func testGetActionWithEmptyDescription() {
        let action = CloseActionManager.getAction(from: "")
        XCTAssertEqual(action.rawValue, CloseAction.unknown.rawValue)
    }
}
