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

@testable import InternalTestApp

class TestCaseManagerTest: XCTestCase {
    
    func testNames() {
        let manager = TestCaseManager()
        
        let tagMarkers: [(tag: TestCaseTag, nameFragment: String)] = [
            (.inapp, "(In-App)"),
            (.gam, "(GAM)")
        ]
        
        for testCase in manager.testCases {
            for testTag in tagMarkers {
                XCTAssertEqual(testCase.title.contains(testTag.nameFragment),
                               testCase.tags.contains { tag in
                                    tag.rawValue == testTag.tag.rawValue
                               },
                               "\(testCase.title): \(testCase.tags.map { "\($0)" }.joined(separator: ", ")) ?")
            }
        }
    }
    
}
