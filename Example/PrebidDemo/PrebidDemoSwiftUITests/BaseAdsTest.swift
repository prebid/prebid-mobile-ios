//
//  BaseAdsTest.swift
//  PrebidDemoTests
//
//  Created by mac-admin on 09.11.2022.
//  Copyright © 2022 Prebid. All rights reserved.
//

import XCTest

class BaseAdsTest: XCTestCase {
    let app = XCUIApplication()
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    public func testTransition() {
        goToAd(adServer: "GAM", adName: "Simple Banner")
    }
    
    override func tearDownWithError() throws {
    
    }
    public func testAd(adServer: String, adName: String) {
        goToAd(adServer: adServer, adName: adName)
    }
    func checkAd(){}

    private func goToAd(adServer: String, adName: String) {
        app.segmentedControls.buttons[adServer].tap()
        app.buttons[adName].tap()
    }

}
