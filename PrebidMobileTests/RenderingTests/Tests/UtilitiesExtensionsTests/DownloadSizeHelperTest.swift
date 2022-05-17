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

class DownloadSizeHelperTest: XCTestCase {
    
    private let nonexistsFile = "nonexist"
    
    override func tearDown() {
        MockServer.shared.reset()
    }
    
    func testSize() {
        
        let testInfo:[(String,Int)] = [
            ("small.mp4",  323553),
            ("medium.mp4", 4605333),
            ("large.mp4",  58303127),
            (nonexistsFile, 0)
        ]
        
        for (filename, expectedSize) in testInfo {
            
            let connection = UtilitiesForTesting.createConnectionForMockedTest()
            
            let rule = MockServerRule(urlNeedle: "http://get_video", mimeType:  MockServerMimeType.MP4.rawValue, connectionID: connection.internalID, fileName: filename)
            MockServer.shared.resetRules([rule])
            
            let expectationNoRestriction = self.expectation(description: "expectationNoRestriction")
            let expectationWithRestriction = self.expectation(description: "expectationWithRestriction")
            
            let downloadSizeHelper = PBMDownloadDataHelper(serverConnection:connection)
            let url = URL(string:"http://get_video")!
            
            // Without size restriction
            downloadSizeHelper.downloadData(for: url, completionClosure: { (data:Data?, error:Error?) in
                guard let actual = data?.count else {
                    XCTFail("sizeInBytes is nil for \(filename)")
                    return
                }
                
                XCTAssert(expectedSize == actual, "Expected \(expectedSize), got \(actual)")
                expectationNoRestriction.fulfill()
            })
            
            // With size restriction
            downloadSizeHelper.downloadData(for: url, maxSize: 10, completionClosure: { (data:Data?, error:Error?) in
                XCTAssertNil(data)
                expectationWithRestriction.fulfill()
            })
            
            self.waitForExpectations(timeout: 2, handler:nil)
        }
    }
}
