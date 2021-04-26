//
//  PBMVASTFailToLoadTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class PBMVASTFailToLoadTest: XCTestCase, PBMAdLoadManagerDelegate {
    
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
        
        let adConfiguration = PBMAdConfiguration()
        adConfiguration.adFormat = .videoInternal
        
        let adLoadManager = PBMAdLoadManagerVAST(connection: conn, adConfiguration: PBMAdConfiguration())
        adLoadManager.adLoadManagerDelegate = self
        adLoadManager.adConfiguration = adConfiguration
        
        if let string = UtilitiesForTesting.loadFileAsStringFromBundle(file) {
            adLoadManager.load(from: string)
        }
        
        self.waitForExpectations(timeout: 2)
    }
    
    //MARK: PBMAdLoadManagerDelegate
    
    func loadManager(_ loadManager: PBMAdLoadManagerProtocol, didLoad transaction: PBMTransaction) {
        XCTFail()
    }
    
    func loadManager(_ loadManager: PBMAdLoadManagerProtocol, failedToLoad transaction: PBMTransaction?, error: Error) {
        failedToLoadAdExpectation?.fulfill()
    }
}
