//
//  SafariOpenerTests.swift
//  PrebidMobileTests
//
//  Created by Olena Stepaniuk on 06.03.2023.
//  Copyright © 2023 AppNexus. All rights reserved.
//

import XCTest
@testable import PrebidMobile

final class SafariOpenerTests: XCTestCase {

    var creative: MockPBMAbstractCreative?
    
    var vc = UIViewController()
    let clickthroughURL = URL(string: "https://prebid.org/")!
    
    override func setUp() {
        super.setUp()
        
        let adConfig = AdConfiguration()
        let creativeModel = PBMCreativeModel(adConfiguration: adConfig)
        let transaction = PBMTransaction(serverConnection: MockServerConnection(), adConfiguration: adConfig, models: [creativeModel])
        
        creative = MockPBMAbstractCreative(creativeModel: creativeModel, transaction: transaction)
        creative?.modalManager = PBMModalManager()
        creative?.viewControllerForPresentingModals = vc
    }
    
    func testOpenClickthrough_onWillLoadURLInClickthroughCall() {
        
        XCTAssert(creative?.clickthroughVisible == false)
        
        _ = creative?.handleNormalClickthrough(
            clickthroughURL,
            sdkConfiguration: Prebid.shared,
            onExit: {})
        
        XCTAssert(creative?.clickthroughVisible == true)
    }

    func testSafariViewControllerDidFinish_onClickthroughPoppedBlockCall() {
        
        let clickthroughPoppedExpecation = expectation(description: "onClickthroughPoppedBlock called.")
        
        creative?.modalManagerDidFinishPopCallback = {
            clickthroughPoppedExpecation.fulfill()
        }
        
        _ = creative?.handleNormalClickthrough(
            clickthroughURL,
            sdkConfiguration: Prebid.shared,
            onExit: {})
        
        creative?.safariOpener?.safariViewControllerDidFinish(creative!.safariOpener!.safariViewController!)
        
        waitForExpectations(timeout: 3)
    }
    
    func testSafariViewControllerDidFinish_onClickthroughExitBlockCall() {
        
        let clickthroughExitExpecation = expectation(description: "onClickthroughExitBlock called.")
        
        _ = creative?.handleNormalClickthrough(
            clickthroughURL,
            sdkConfiguration: Prebid.shared,
            onExit: {
                clickthroughExitExpecation.fulfill()
            })
        
        creative?.safariOpener?.safariViewControllerDidFinish(creative!.safariOpener!.safariViewController!)
        
        waitForExpectations(timeout: 3)
    }
    
    func testOpenInExternalBrowser_onDidLeaveAppBlockCall() {
        guard #available(iOS 14.0, *) else {
            return
        }
        
        let clickthroughOpenInBrowserExpecation = expectation(description: "onDidLeaveAppBlock called.")
        
        creative?.modalManagerDidLeaveAppCallback = {
            clickthroughOpenInBrowserExpecation.fulfill()
        }
        
        _ = creative?.handleNormalClickthrough(
            clickthroughURL,
            sdkConfiguration: Prebid.shared,
            onExit: {})
        
        
        creative?.safariOpener?.safariViewControllerWillOpenInBrowser(creative!.safariOpener!.safariViewController!)
        
        waitForExpectations(timeout: 3)
    }
}
