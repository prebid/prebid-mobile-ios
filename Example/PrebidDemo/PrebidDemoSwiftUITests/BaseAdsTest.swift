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
//    var viewController: IndexController?
    override func setUpWithError() throws {
        continueAfterFailure = true
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        viewController = storyboard.instantiateViewController(withIdentifier: "index") as? IndexController
//        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
//        appDelegate.window?.rootViewController = viewController
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
