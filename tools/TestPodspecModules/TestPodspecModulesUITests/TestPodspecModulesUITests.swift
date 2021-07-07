//
//  TestPodspecModulesUITests.swift
//  TestPodspecModulesUITests
//
//  Created by Vadim Khohlov on 6/29/21.
//

import XCTest

class TestPodspecModulesUITests: XCTestCase {

    var app : XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }

    func testSDKVersion() {
        
        Thread.sleep(forTimeInterval: 2)

        let sdkLabel = app.staticTexts["rendering_sdk_version_label"]
        let projectLabel = app.staticTexts["project_version_label"]
        XCTAssertEqual(sdkLabel.label, projectLabel.label)
    }
}
