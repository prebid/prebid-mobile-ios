//
//  OXAMoPubInterstitialAdUnitTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXAMoPubInterstitialAdUnitTest: XCTestCase {
    private let sdkConfiguration: OXASDKConfiguration = {
        let config = OXASDKConfiguration()
        config.serverURL = OXASDKConfiguration.devintServerURL
        config.accountID = OXASDKConfiguration.devintAccountID
        return config
    }()
    private let targeting = OXATargeting.withDisabledLock
    
    func testDefaultSettings() {
        let adUnit = OXAMoPubInterstitialAdUnit(configId: "prebidConfigId", minSizePercentage: CGSize(width: 30, height: 30))
        let adUnitConfig = adUnit.adUnitConfig
        
        XCTAssertTrue(adUnitConfig.isInterstitial)
        OXMAssertEq(adUnitConfig.adPosition, .fullScreen)
        XCTAssertEqual(adUnitConfig.videoPlacementType.rawValue, 5)
    }
    
    func testWrongAdObject() {
        let adUnit = OXAMoPubInterstitialAdUnit(configId: "prebidConfigId", minSizePercentage: CGSize(width: 30, height: 30))
        let asyncExpectation = expectation(description: "fetchDemand executed")
        adUnit.fetchDemand(with: NSString()) { result in
            XCTAssertEqual(result, .wrongArguments)
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }
    
    func testAdObjectSetUpCleanUp() {
        @objc class MoPubAdObject: NSObject, OXAMoPubAdObjectProtocol  {
            var keywords: String?
            var localExtras: [AnyHashable : Any]?
        }
        
        //a good response with a bid
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(OXABidResponseTransformer.someValidResponse)
            }])
        let initialKeywords = "key1,key2"
        
        let adObject = MoPubAdObject()
        adObject.keywords = initialKeywords
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnit = OXAMoPubInterstitialAdUnit(configId: configId, minSizePercentage: CGSize(width: 30, height: 30))
        
        let asyncExpectation = expectation(description: "fetchDemand executed")
        
        adUnit.fetchDemand(with: adObject,
                           connection: connection,
                           sdkConfiguration: sdkConfiguration,
                           targeting: targeting)
        { result in
            XCTAssertEqual(result, .ok)
            
            let resultKeywords = adObject.keywords!
            XCTAssertTrue(resultKeywords.contains("hb_pb:0.10"))
            
            let resultExtras: [AnyHashable : Any] = adObject.localExtras!
            XCTAssertEqual(resultExtras.count, 2)
            XCTAssertEqual(resultExtras[OXAMoPubConfigIdKey] as! String, configId)
            let bid = resultExtras[OXAMoPubAdUnitBidKey] as! NSObject
            XCTAssertTrue(bid.isKind(of: OXABid.self))
            
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
        
        //a bad response with the same ad object without bids
        
        let noBidConnection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(OXABidResponseTransformer.serverErrorResponse)
            }])
        
        let asyncExpectation2 = expectation(description: "fetchDemand executed")
        
        adUnit.fetchDemand(with: adObject,
                           connection: noBidConnection,
                           sdkConfiguration: sdkConfiguration,
                           targeting: targeting)
        { result in
            XCTAssertEqual(result, .serverError)
            
            let resultKeywords = adObject.keywords!
            XCTAssertEqual(resultKeywords, initialKeywords)
            let resultExtras: [AnyHashable : Any] = adObject.localExtras!
            XCTAssertEqual(resultExtras.count, 0)
            
            asyncExpectation2.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }

}
