//
//  OXMVastLoaderCheckForAds.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation

import XCTest
import CoreFoundation

@testable import OpenXApolloSDK

class OXMVastLoaderCheckForAds : XCTestCase {

    let sdkConfiguration = OXASDKConfiguration()
    
    var wrapper1:OXMVastWrapperAd! = nil
    var wrapper2:OXMVastWrapperAd! = nil
    var inline:OXMVastInlineAd! = nil

    var response1:OXMVastResponse!
    var response2:OXMVastResponse!
    var response3:OXMVastResponse!
    
    var vastAdsBuilder:OXMVastAdsBuilder?
    
    var expectationResponse1ErrorURICalled:XCTestExpectation!
    var expectationResponse2ErrorURICalled:XCTestExpectation!
    var expectationResponse3ErrorURICalled:XCTestExpectation!
    
    override func setUp() {

        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        self.vastAdsBuilder = OXMVastAdsBuilder(connection: connection)
        
        wrapper1 = OXMVastWrapperAd()
        wrapper2 = OXMVastWrapperAd()
        inline = OXMVastInlineAd()
        
        response1 = OXMVastResponse()
        response2 = OXMVastResponse()
        response3 = OXMVastResponse()
        
        response1.noAdsResponseURI = "http://response1/noAds"
        response2.noAdsResponseURI = "http://response2/noAds"
        response3.noAdsResponseURI = "http://response3/noAds"
        
        MockServer.singleton().reset()
        let rule1 =  MockServerRule(fireAndForgetURLNeedle: response1.noAdsResponseURI!, connectionID: connection.internalID)
        rule1.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.fulfillOrFail(self.expectationResponse1ErrorURICalled, "expectationResponse1ErrorURICalled")
        }

        let rule2 = MockServerRule(fireAndForgetURLNeedle: response2.noAdsResponseURI!, connectionID: connection.internalID)
        rule2.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.fulfillOrFail(self.expectationResponse2ErrorURICalled, "expectationResponse2ErrorURICalled")
        }
        
        let rule3 = MockServerRule(fireAndForgetURLNeedle: response3.noAdsResponseURI!, connectionID: connection.internalID)
        rule3.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            self.fulfillOrFail(self.expectationResponse3ErrorURICalled, "expectationResponse3ErrorURICalled")
        }
        
        MockServer.singleton().resetRules([rule1, rule2, rule3])
    }
    
    override func tearDown() {
        self.vastAdsBuilder = nil
        self.expectationResponse1ErrorURICalled = nil
        self.expectationResponse2ErrorURICalled = nil
        self.expectationResponse3ErrorURICalled = nil
        MockServer.singleton().reset()
    }
    
    
    //A single response with an ad, whether it's an inline or wrapper should pass and not fire NoAds URIs.
    func testPositiveSingleInlineOrWrapper() {
        response1.vastAbstractAds = [inline!]
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == false)
        
        response1.vastAbstractAds = [wrapper1!]
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == false)
    }

    //A response with no ads should fire the response's noAdsURI.
    func testNegativeSingleNoAds() {
        self.expectationResponse1ErrorURICalled = self.expectation(description: "expectationResponse1ErrorURICalled")
        
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == true)
        
        self.waitForExpectations(timeout: 1.0, handler:nil)
    }
    
    func testPositiveTwoResponses() {
        response1.vastAbstractAds = [wrapper1!]
        wrapper1.vastResponse = response2
        response2.parentResponse = response1
        
        response2.vastAbstractAds = [inline!]
        
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == false)
    }
    
    //A response with a nextResponse but no ads should fire that response's noAdsURI.
    func testNegativeTwoResponsesNoAdsOnSecond() {
        self.expectationResponse1ErrorURICalled = self.expectation(description: "expectationResponse1ErrorURICalled")
        self.expectationResponse2ErrorURICalled = self.expectation(description: "expectationResponse2ErrorURICalled")
        
        response1.vastAbstractAds = [wrapper1!]
        wrapper1.vastResponse = response2
        
        //No Ads on response2
        response2.parentResponse = response1
        
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == true)
        
        self.waitForExpectations(timeout: 1.0, handler:nil)
    }

    func testPositiveThreeResponses() {
        
        response1.vastAbstractAds = [wrapper1!]
        wrapper1.vastResponse = response2
        
        response2.parentResponse = response1
        response2.vastAbstractAds = [wrapper2!]
        wrapper2.vastResponse = response3
        
        response3.parentResponse = response2
        response3.vastAbstractAds = [inline!]
        
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == false)
    }

    func testNegativeThreeResponsesNoAdsOnLast() {
        
        self.expectationResponse1ErrorURICalled = self.expectation(description: "expectationResponse1ErrorURICalled")
        self.expectationResponse2ErrorURICalled = self.expectation(description: "expectationResponse2ErrorURICalled")
        self.expectationResponse3ErrorURICalled = self.expectation(description: "expectationResponse3ErrorURICalled")
        
        response1.vastAbstractAds = [wrapper1!]
        wrapper1.vastResponse = response2
        
        response2.parentResponse = response1
        response2.vastAbstractAds = [wrapper2!]
        wrapper2.vastResponse = response3
        
        //No ads on response3
        response3.parentResponse = response2
        
        XCTAssert(vastAdsBuilder?.checkHasNoAdsAndFireURIs(vastResponse: response1) == true)
        self.waitForExpectations(timeout: 1.0, handler:nil)
    }
}
