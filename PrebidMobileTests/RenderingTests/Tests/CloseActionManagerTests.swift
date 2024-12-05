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

class PBMCloseActionManagerTests: XCTestCase {

    func testGetActionWithCloseButtonDescription() {
        let action = PBMCloseActionManager.getActionWithDescription("closebutton")
        XCTAssertEqual(action.rawValue, PBMCloseAction.closeButton.rawValue)
    }

    func testGetActionWithAutoCloseDescription() {
        let action = PBMCloseActionManager.getActionWithDescription( "autoclose")
        XCTAssertEqual(action.rawValue, PBMCloseAction.autoClose.rawValue)
    }

    func testGetActionWithUnknownDescription() {
        let action = PBMCloseActionManager.getActionWithDescription("unknown")
        XCTAssertEqual(action.rawValue, PBMCloseAction.unknown.rawValue)
    }

    func testGetActionWithEmptyDescription() {
        let action = PBMCloseActionManager.getActionWithDescription("")
        XCTAssertEqual(action.rawValue, PBMCloseAction.unknown.rawValue)
    }
}
