//
//  MediaFileTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
import XCTest
@testable import OpenXApolloSDK

class OXMAdRequesterVASTTest: XCTestCase {
    
    var successfulExpectation:XCTestExpectation?
    var failedExpectation:XCTestExpectation?
    
    var vastServerResponse: OXMAdRequestResponseVAST?
    
    override func setUp() {
        MockServer.singleton().reset()
    }
    
    override func tearDown() {
        MockServer.singleton().reset()
        self.successfulExpectation = nil
        self.failedExpectation = nil
    }
    
    func testSuccess() {
        self.successfulExpectation = self.expectation(description: "Expected VAST Load to be successful")
        vastServerResponse = nil
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()

        let ruleInline =  MockServerRule(urlNeedle: "foo.com/inline/vast", mimeType:  MockServerMimeType.XML.rawValue, connectionID: conn.internalID, fileName: "document_with_one_inline_ad.xml")
        
        MockServer.singleton().resetRules([ruleInline])
        
        let adConfiguration = OXMAdConfiguration()
        
        let adLoadManager = MockOXMAdLoadManagerVAST(connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.successfulExpectation?.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            self.failedExpectation?.fulfill()
        }
        
        let requester = OXMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("document_with_one_wrapper_ad.xml")  {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 2)

        XCTAssertNotNil(vastServerResponse)
    }
    
    func testFailed() {
        
        self.failedExpectation = self.expectation(description: "Expected VAST Load to be failed")
        vastServerResponse = nil
        
        let conn = OXMServerConnection()
        let adConfiguration = OXMAdConfiguration()
        
        let adLoadManager = MockOXMAdLoadManagerVAST(connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.successfulExpectation?.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            self.failedExpectation?.fulfill()
        }
        
        let requester = OXMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("VAST_Empty_Response.xml")  {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 2)

        XCTAssertNil(vastServerResponse)
    }
    
    func testVastLoaderFacade () {
        //Make an OXMAdConfiguration
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.adFormat = .video
        
        self.successfulExpectation = self.expectation(description: "Expected VAST Load to be successful")
        
        let conn = UtilitiesForTesting.createConnectionForMockedTest()
        let adLoadManager = MockOXMAdLoadManagerVAST(connection:conn, adConfiguration: adConfiguration)
        
        adLoadManager.mock_requestCompletedSuccess = { response in
            self.vastServerResponse = response
            self.successfulExpectation?.fulfill()
        }
        
        adLoadManager.mock_requestCompletedFailure = { error in
            self.failedExpectation?.fulfill()
        }
        
        let requester = OXMAdRequesterVAST(serverConnection:conn, adConfiguration: adConfiguration)
        requester.adLoadManager = adLoadManager
        
        if let data = UtilitiesForTesting.loadFileAsDataFromBundle("inline_with_padding_on_urls.xml") {
            requester.buildAdsArray(data)
        }
        
        self.waitForExpectations(timeout: 2)
        
        XCTAssertNotNil(self.vastServerResponse)
        if self.vastServerResponse == nil {
            return
        }
        
        let vastRequestErrorExpectation = self.expectation(description: "Expected wrapper limit")
        
        let modelMaker = OXMCreativeModelCollectionMakerVAST(serverConnection:conn, adConfiguration: adConfiguration)
        
        modelMaker.makeModels(self.vastServerResponse!,
                              successCallback: { models in
                                XCTAssertEqual(models.count, 1)
                                let model = models.first! as OXMCreativeModel
                                XCTAssert(model.videoFileURL == "http://i.cdn.openx.com/videos/mobile/OpenX_15_Seconds_Fade_Small.mp4")
                                vastRequestErrorExpectation.fulfill()
        },
                              failureCallback: { error in
                                XCTFail(error.localizedDescription)
                                vastRequestErrorExpectation.fulfill()
        })
        
        self.waitForExpectations(timeout: 3)
    }
}
