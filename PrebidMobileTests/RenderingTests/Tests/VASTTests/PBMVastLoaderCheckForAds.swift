/*   Copyright 2018-2021 Prebid.org, Inc.
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
  http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

import Foundation

import XCTest
import CoreFoundation

@testable import PrebidMobile

class PBMVastLoaderCheckForAds : XCTestCase {
    
    let sdkConfiguration = Prebid.mock
    
    var wrapper1:PBMVastWrapperAd! = nil
    var wrapper2:PBMVastWrapperAd! = nil
    var inline:PBMVastInlineAd! = nil
    
    var response1:PBMVastResponse!
    var response2:PBMVastResponse!
    var response3:PBMVastResponse!
    
    var vastAdsBuilder:PBMVastAdsBuilder?
    
    var expectationResponse1ErrorURICalled:XCTestExpectation!
    var expectationResponse2ErrorURICalled:XCTestExpectation!
    var expectationResponse3ErrorURICalled:XCTestExpectation!
    
    override func setUp() {
        
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        self.vastAdsBuilder = PBMVastAdsBuilder(connection: connection)
        
        wrapper1 = PBMVastWrapperAd()
        wrapper2 = PBMVastWrapperAd()
        inline = PBMVastInlineAd()
        
        response1 = PBMVastResponse()
        response2 = PBMVastResponse()
        response3 = PBMVastResponse()
        
        response1.noAdsResponseURI = "http://response1/noAds"
        response2.noAdsResponseURI = "http://response2/noAds"
        response3.noAdsResponseURI = "http://response3/noAds"
        
        MockServer.shared.reset()
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
        
        MockServer.shared.resetRules([rule1, rule2, rule3])
    }
    
    override func tearDown() {
        self.vastAdsBuilder = nil
        self.expectationResponse1ErrorURICalled = nil
        self.expectationResponse2ErrorURICalled = nil
        self.expectationResponse3ErrorURICalled = nil
        MockServer.shared.reset()
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
