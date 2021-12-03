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

import XCTest
@testable import PrebidMobile

class PBMVastIconTest: XCTestCase {
    
    func testDefaultState() {
        let icon = PBMVastIcon()
        
        XCTAssertNotNil(icon.program)
        XCTAssertEqual(icon.program, "")
        
        XCTAssertEqual(icon.width, 0)
        XCTAssertEqual(icon.height, 0)
        XCTAssertEqual(icon.xPosition, 0)
        XCTAssertEqual(icon.yPosition, 0)
        XCTAssertEqual(icon.startOffset, 0)
        XCTAssertEqual(icon.duration, 0)
        
        
        XCTAssertNil(icon.clickThroughURI)
        XCTAssertEqual(icon.clickTrackingURIs as! [String], [String]())
        XCTAssertNil(icon.viewTrackingURI)
        
        // computed later
        XCTAssertFalse(icon.displayed)
        
        // PBMVastResourceContainer
        XCTAssertEqual(icon.resourceType, PBMVastResourceType.staticResource)
        XCTAssertNil(icon.resource)
        XCTAssertNil(icon.staticType)
    }
}
