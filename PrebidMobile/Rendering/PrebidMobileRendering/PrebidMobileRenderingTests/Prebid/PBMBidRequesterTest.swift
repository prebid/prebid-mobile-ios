//
//  PBMBidRequesterTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMBidRequesterTest: XCTestCase {
    private var sdkConfiguration: PBMSDKConfiguration!
    private let targeting = PBMTargeting.withDisabledLock
    
    override func setUp() {
        super.setUp()
        sdkConfiguration = PBMSDKConfiguration()
//        sdkConfiguration.serverURL = PBMSDKConfiguration.devintServerURL
        try! sdkConfiguration.setCustomPrebidServer(url: PBMSDKConfiguration.devintServerURL)
        sdkConfiguration.accountID = PBMSDKConfiguration.devintAccountID
    }

    override func tearDown() {
        sdkConfiguration = nil
        super.tearDown()
    }
    
    func testBanner_300x250() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configID: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(PBMBidResponseTransformer.someValidResponse)
            }])
        let requester = PBMBidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        requester.requestBids { (bidResponse, error) in
            exp.fulfill()
            if let error = error {
                XCTFail(error.localizedDescription)
                return
            }
            XCTAssertNotNil(bidResponse)
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidAccountID_noRequest() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configID: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection()
        let requester = PBMBidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        sdkConfiguration.accountID = " \t \t  "
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(error as NSError?, PBMError.invalidAccountId as NSError?)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidAccountID_rejectedByServer() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let accountID = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configID: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(PBMBidResponseTransformer.invalidAccountIDResponse(accountID: accountID))
            }])
        let requester = PBMBidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        sdkConfiguration.accountID = accountID
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(error as NSError?, PBMError.invalidAccountId as NSError?)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidConfigID_noRequest() {
        let adUnitConfig = AdUnitConfig(configID: " \t \t  ", size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection()
        let requester = PBMBidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(error as NSError?, PBMError.invalidConfigId as NSError?)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidConfigID_rejectedByServer() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configID: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(PBMBidResponseTransformer.invalidConfigIdResponse(configId: configId))
            }])
        let requester = PBMBidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertEqual(error as NSError?, PBMError.invalidConfigId as NSError?)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidSize() {
        let adUnitConfig = AdUnitConfig(configID: "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4", size: CGSize(width: -300, height: 250))
        let connection = MockServerConnection()
        let requester = PBMBidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_invalidAdditionalSize() {
        let adUnitConfig = AdUnitConfig(configID: "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4", size: CGSize(width: 300, height: 250))
        adUnitConfig.additionalSizes = [CGSize(width: -320, height: 50)]
        
        let connection = MockServerConnection()
        let requester = PBMBidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testBanner_requestInProgress() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configID: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                callback(PBMBidResponseTransformer.someValidResponse)
            }
            }])
        let requester = PBMBidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp_ok = expectation(description: "exp_ok")
        let exp_fail = expectation(description: "exp_fail")
        
        requester.requestBids { (bidResponse, error) in
            exp_ok.fulfill()
            if let error = error {
                XCTFail(error.localizedDescription)
                return
            }
            XCTAssertNotNil(bidResponse)
        }
        
        requester.requestBids { (bidResponse, error) in
            XCTAssertNil(bidResponse)
            XCTAssertNotNil(error)
            exp_fail.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
}
