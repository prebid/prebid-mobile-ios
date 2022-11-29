//
//  BaseAdsTest.swift
//  PrebidDemoTests
//
//  Created by mac-admin on 09.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import XCTest
@testable import PrebidDemoSwift

class BaseAdsTest: XCTestCase {
    
    let app = XCUIApplication()
    let testCases = TestCases()
    override func setUpWithError() throws {
        continueAfterFailure = false
//        app.launch()
//        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle)
//        let controller = storyboard.instantiateViewController(withIdentifier: "banner")
//        UIApplication.shared.keyWindow?.rootViewController = controller
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testAd(testCase: String) {
        goToAd(testCase: testCase)
        checkAd(testCase: testCase)
    }
    func checkAd(testCase: String) {}

    func assertFailedMessage(testCase: String, reason: String) -> String {
        return "Ad Failed \(testCase): \(reason)"
    }
    
    private func goToAd(testCase: String) {
        app.launch()
        app.searchFields.element.tap()
        app.searchFields.element.typeText(testCase)
        app.tables.element(boundBy: 0).cells.element(boundBy: 0).tap()
    }

}
