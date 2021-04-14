//
//  OXMVASTFailToLoadTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class OXMVASTFailToLoadTest: XCTestCase, OXMAdLoadManagerDelegate {
    
    var failedToLoadAdExpectation:XCTestExpectation?
    
    func testAdLoadManagerVastEmptyResponse() {
        failedToLoadAdExpectation = self.expectation(description: "Expected failedToLoadAd to be called")
        loadAdLoadManager(file: "VAST_Empty_Response.xml")
    }
    
    func testAdLoadManagerVastEmptyResponse2() {
        failedToLoadAdExpectation = self.expectation(description: "Expected failedToLoadAd to be called")
        loadAdLoadManager(file: "VAST_Empty_Response2.xml")
    }
    
    func testAdLoadManagerVastEmptyVideoAd() {
        failedToLoadAdExpectation = self.expectation(description: "Expected failedToLoadAd to be called")
        loadAdLoadManager(file: "VAST_Empty_Inline.xml")
    }
    
    func loadAdLoadManager(file: String) {
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.adFormat = .video
        
        let adLoadManager = OXMAdLoadManagerVAST(connection: conn, adConfiguration: OXMAdConfiguration())
        adLoadManager.adLoadManagerDelegate = self
        adLoadManager.adConfiguration = adConfiguration
        
        if let string = UtilitiesForTesting.loadFileAsStringFromBundle(file) {
            adLoadManager.load(from: string)
        }
        
        self.waitForExpectations(timeout: 2)
    }
    
    //MARK: OXMAdLoadManagerDelegate
    
    func loadManager(_ loadManager: OXMAdLoadManagerProtocol, didLoad transaction: OXMTransaction) {
        XCTFail()
    }
    
    func loadManager(_ loadManager: OXMAdLoadManagerProtocol, failedToLoad transaction: OXMTransaction?, error: Error) {
        failedToLoadAdExpectation?.fulfill()
    }
}
