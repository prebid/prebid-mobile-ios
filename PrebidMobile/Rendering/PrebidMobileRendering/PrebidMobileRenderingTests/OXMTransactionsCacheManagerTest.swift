//
//  PBMTransactionsCacheManagerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class PBMTransactionsCacheManagerTest: XCTestCase {
    
    var expectationPreloadCompleted: XCTestExpectation?
    var expectationTransaction1: XCTestExpectation?
    var expectationTransaction2: XCTestExpectation?

    // This test loads TWO VAST ads into the transaction cache
    func testPreloadWithTags() {
        
        // PREAPRE MOCKS
        
        let vastURL1 = "foo.com/inline1"
        let vastURL2 = "foo.com/inline2"
        
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        var inlineResponse = UtilitiesForTesting.loadFileAsStringFromBundle("openx_vast_response.xml")!
        let needle = MockServerMimeType.MP4.rawValue
        let replaceWith = MockServerMimeType.MP4.rawValue
        inlineResponse = inlineResponse.PBMstringByReplacingRegex(needle, replaceWith:replaceWith)
        
        let ruleVAST1 = MockServerRule(urlNeedle: vastURL1, mimeType:  MockServerMimeType.XML.rawValue, connectionID: connection.internalID, strResponse: inlineResponse)
        let ruleVAST2 = MockServerRule(urlNeedle: vastURL2, mimeType:  MockServerMimeType.XML.rawValue, connectionID: connection.internalID, strResponse: inlineResponse)

        let ruleVideo = MockServerRule(urlNeedle: "http://get_video_file", mimeType:  MockServerMimeType.MP4.rawValue, connectionID: connection.internalID, fileName: "small.mp4")
        MockServer.singleton().resetRules([ruleVAST1, ruleVAST2, ruleVideo])
        
        // EXPECTATIONS
        
        expectationPreloadCompleted = expectation(description: "expectationPreloadCompleted")
        expectationTransaction1 = expectation(description: "expectationTransaction1")
        expectationTransaction2 = expectation(description: "expectationTransaction2")
        
        // RUN
        
        let cache = MockTransactionsCache()
        cache.testAddTransactionClosure = { transaction in
//            if transaction.adConfiguration.domain == vastURL1 {
//                self.expectationTransaction1?.fulfill()
//            } else if transaction.adConfiguration.domain == vastURL2 {
//                self.expectationTransaction2?.fulfill()
//            }
        }
        
        let config1 = PBMAdConfiguration()
//        config1.domain = vastURL1
//        config1.auid = "12345"
        config1.adFormat = .video
        let config2 = PBMAdConfiguration()
//        config2.domain = vastURL2
//        config2.auid = "67890"
        config2.adFormat = .video

        let vastTags = [config1, config2]
        
        let cacheManager = PBMTransactionsCacheManager(transactionsCache: cache)
        cacheManager.preloadAds(with: vastTags, serverConnection: connection, completion: {
            self.expectationPreloadCompleted?.fulfill()
        })
        
        waitForExpectations(timeout: 3)
    }
    
    func testPreloadWithAddConfiguration() {

        // PREAPRE MOCKS

        let vastURL = "foo.com/inline1"
        
        //Make an PBMServerConnection and redirect its network requests to the Mock Server
        let connection = UtilitiesForTesting.createConnectionForMockedTest()
        
        //Change the inline response to claim that it will respond with m4v
        var inlineResponse = UtilitiesForTesting.loadFileAsStringFromBundle("openx_vast_response.xml")!
        let needle = MockServerMimeType.MP4.rawValue
        let replaceWith = MockServerMimeType.MP4.rawValue
        inlineResponse = inlineResponse.PBMstringByReplacingRegex(needle, replaceWith:replaceWith)
        
        let ruleVAST = MockServerRule(urlNeedle: vastURL, mimeType:  MockServerMimeType.XML.rawValue, connectionID: connection.internalID, strResponse: inlineResponse)
        
        let ruleVideo = MockServerRule(urlNeedle: "http://get_video_file", mimeType:  MockServerMimeType.MP4.rawValue, connectionID: connection.internalID, fileName: "small.mp4")
        MockServer.singleton().resetRules([ruleVAST, ruleVideo])
        
        // EXPECTATIONS

        expectationPreloadCompleted = expectation(description: "expectationPreloadCompleted")
        expectationTransaction1 = expectation(description: "expectationTransaction1")
        
        // RUN
        
        let cache = MockTransactionsCache()
        cache.testAddTransactionClosure = { transaction in
            self.expectationTransaction1?.fulfill()
        }
        
        let adConfiguration = PBMAdConfiguration()
        adConfiguration.adFormat = .video
//        adConfiguration.domain = vastURL
//        adConfiguration.auid = "12345"

        let cacheManager = PBMTransactionsCacheManager(transactionsCache: cache)
        cacheManager.preloadAd(with: adConfiguration, serverConnection: connection, completion: {
            self.expectationPreloadCompleted?.fulfill()
        })
        
        waitForExpectations(timeout: 3)
    }
}
