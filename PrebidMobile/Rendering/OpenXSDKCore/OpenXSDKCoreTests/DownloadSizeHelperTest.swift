//
//  DownloadSizeHelperTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

@testable import OpenXApolloSDK

import XCTest

class DownloadSizeHelperTest: XCTestCase {

    private let nonexistsFile = "nonexist"
    
    override func tearDown() {
        MockServer.singleton().reset()
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
            MockServer.singleton().resetRules([rule])
            
            let expectationNoRestriction = self.expectation(description: "expectationNoRestriction")
            let expectationWithRestriction = self.expectation(description: "expectationWithRestriction")

            let downloadSizeHelper = OXMDownloadDataHelper(oxmServerConnection:connection)
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
