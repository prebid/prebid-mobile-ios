//
//  TestCaseTagTest.swift
//  OpenXInternalTestAppTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileDemoRendering

class TestCaseTagTest: XCTestCase {
    
    let testEmptyTags: [TestCaseTag] = []
    
    func testExtractAppearances() {
        XCTAssertEqual(TestCaseTag.extractAppearances(from: testEmptyTags)                      , testEmptyTags)
        XCTAssertEqual(TestCaseTag.extractAppearances(from: TestCaseTag.appearance)             , TestCaseTag.appearance.sorted(by: <=))
        
        XCTAssertEqual(TestCaseTag.extractAppearances(from: [.banner, .interstitial, .video])   , [.banner, .interstitial, .video])
        XCTAssertEqual(TestCaseTag.extractAppearances(from: [.banner, .mock])                   , [.banner])
        XCTAssertEqual(TestCaseTag.extractAppearances(from: [.server])                          , testEmptyTags)
    }
    
    func testExtractConnections() {
        XCTAssertEqual(TestCaseTag.extractConnections(from: testEmptyTags)                      , testEmptyTags)
        XCTAssertEqual(TestCaseTag.extractConnections(from: TestCaseTag.connections)            , TestCaseTag.connections.sorted(by: <=))
        
        XCTAssertEqual(TestCaseTag.extractConnections(from: [.mock])                            , [.mock])
        XCTAssertEqual(TestCaseTag.extractConnections(from: [.server, .interstitial])              , [.server])
        XCTAssertEqual(TestCaseTag.extractConnections(from: [.banner, .interstitial])           , testEmptyTags)
    }
    
    func testExtractIntegrations() {
//        XCTAssertEqual(TestCaseTag.extractIntegrations(from: testEmptyTags)                     , testEmptyTags)
//        XCTAssertEqual(TestCaseTag.extractIntegrations(from: TestCaseTag.integrations)          , TestCaseTag.integrations.sorted(by: <=))
//
//        XCTAssertEqual(TestCaseTag.extractIntegrations(from: [.inapp])                          , [.inapp])
        XCTAssertEqual(TestCaseTag.extractIntegrations(from: [.inapp, .gam])                    , [.inapp, .gam])
        XCTAssertEqual(TestCaseTag.extractIntegrations(from: [.mopub, .interstitial])            , [.mopub])
//        XCTAssertEqual(TestCaseTag.extractIntegrations(from: [.banner, .interstitial])           , testEmptyTags)
    }
    
    func testCollectTags() {
        XCTAssertEqual(TestCaseTag.collectTags(from: testEmptyTags      , in: testEmptyTags)            , testEmptyTags)
        
        XCTAssertEqual(TestCaseTag.collectTags(from: [.mock]            , in: testEmptyTags)            , testEmptyTags)
        XCTAssertEqual(TestCaseTag.collectTags(from: testEmptyTags      , in: [.mock] )                 , testEmptyTags)
        XCTAssertEqual(TestCaseTag.collectTags(from: [.mock]            , in: [.mock] )                 , [.mock])
        
        XCTAssertEqual(TestCaseTag.collectTags(from: [.mock, .banner]   , in: [.mock] )                 , [.mock])
        XCTAssertEqual(TestCaseTag.collectTags(from: [.mock, .banner]   , in: [.server] )               , testEmptyTags)
    }
}
