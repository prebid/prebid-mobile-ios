//
//  BaseAdsTest.swift
//  PrebidDemoTests
//
//  Created by mac-admin on 09.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import XCTest
extension String: Error {}

class BaseAdsTest: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = true
    }
    
    override func tearDownWithError() throws {
        
    }
    func testAd(adServer: String, adName: String) {
        goToAd(adServer: adServer, adName: adName)
        checkAd(adServer: adServer, adName: adName)
    }
    func checkAd(adServer: String, adName: String) {}

    private func goToAd(adServer: String, adName: String) {
        app.launch()
        app.segmentedControls.buttons[adServer].tap()
        app.buttons[adName].tap()
    }

}
