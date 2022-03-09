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

import Foundation
import XCTest

class PBMAgeUtilsTest: XCTestCase {
    
    func testYobForAge() {
        let age = 42
        let date = Date()
        let calendar = Calendar.current
        let yob = calendar.component(.year, from: date) - age
        
        XCTAssertEqual(PBMAgeUtils.yob(forAge:age), yob)
    }
    
    func testIsYOBValid() {
        let age = 1985
        XCTAssertTrue(PBMAgeUtils.isYOBValid(age))
    }
    
    func testIsYOBValidWrong() {
        let age1 = 1800
        XCTAssertFalse(PBMAgeUtils.isYOBValid(age1))
        
        let age2 = 2100
        XCTAssertFalse(PBMAgeUtils.isYOBValid(age2))
    }
}
