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
    override func setUpWithError() throws {
        continueAfterFailure = false
//        app.launch()
//        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle)
//        let controller = storyboard.instantiateViewController(withIdentifier: "banner")
//        UIApplication.shared.keyWindow?.rootViewController = controller
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testAd(adServer: String, adName: String) {
        goToAd(adServer: adServer, adName: adName)
        checkAd(adServer: adServer, adName: adName)
    }
    func checkAd(adServer: String, adName: String) {}

    func assertFailedMessage(adServer: String, adName: String, reason: String) -> String {
        return "Ad Failed \(adServer) - \(adName): \(reason)"
    }
    
    private func goToAd(adServer: String, adName: String) {
        app.launch()
        app.segmentedControls.buttons[adServer].tap()
        app.buttons[adName].tap()
    }

}
