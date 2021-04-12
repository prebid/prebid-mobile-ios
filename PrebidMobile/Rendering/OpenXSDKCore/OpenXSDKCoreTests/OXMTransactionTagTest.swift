//
//  OXMTransactionTagTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXMTransactionTagTest: XCTestCase {
    
    func testIsEqual1() {
        // Test with same configuration
        let adConfiguration = OXMAdConfiguration()
//        adConfiguration.domain = "test"
//        adConfiguration.auid = "12345"
        
        let tag1 = OXMTransactionTag(adConfiguration: adConfiguration)
        let tag2 = OXMTransactionTag(adConfiguration: adConfiguration)
        
        XCTAssertEqual(tag1, tag1)
        XCTAssertEqual(tag1, tag2)
        XCTAssertFalse(tag1 === tag2)
    }
    
    func testIsEqual2() {
        let adConfiguration1 = OXMAdConfiguration()
//        adConfiguration1.domain = "test"
//        adConfiguration1.auid = "12345"
//        adConfiguration1.pgid = "67890"
        let tag1 = OXMTransactionTag(adConfiguration: adConfiguration1)
        
        let adConfiguration2 = OXMAdConfiguration()
//        adConfiguration2.domain = "test"
//        adConfiguration2.auid = "12345"
//        adConfiguration2.pgid = "67890"
        let tag2 = OXMTransactionTag(adConfiguration: adConfiguration2)
        
        XCTAssertEqual(tag1, tag1)
        XCTAssertEqual(tag1, tag2)
        XCTAssertFalse(tag1 === tag2)
        
//        adConfiguration1.pgid = nil
        let tag3 = OXMTransactionTag(adConfiguration: adConfiguration1)
//        adConfiguration2.pgid = nil
        let tag4 = OXMTransactionTag(adConfiguration: adConfiguration2)
        XCTAssertEqual(tag3, tag4)
        
//        adConfiguration1.auid = nil
//        adConfiguration1.pgid = "67890"
        let tag5 = OXMTransactionTag(adConfiguration: adConfiguration1)
//        adConfiguration2.auid = nil
//        adConfiguration2.pgid = "67890"
        let tag6 = OXMTransactionTag(adConfiguration: adConfiguration2)
        XCTAssertEqual(tag5, tag6)
    }
    
    func testIsNotEqual1() {
        // Not Equal because of wrong type or domain, auid, and pgid are nil
        let adConfiguration = OXMAdConfiguration()
        
        let tag1 = OXMTransactionTag(adConfiguration: adConfiguration)
        let tag2 = OXMTransactionTag(adConfiguration: adConfiguration)
        
        XCTAssertNotEqual(tag1, adConfiguration)
        XCTAssertNotEqual(tag1, tag1)
        XCTAssertNotEqual(tag1, tag2)
        XCTAssertFalse(tag1 === tag2)
    }
    
    func testIsNotEqual2() {
        
        let adConfiguration1 = OXMAdConfiguration()
//        adConfiguration1.domain = "test"
//        adConfiguration1.auid = "12345"
        adConfiguration1.adFormat = .display
        let tag1 = OXMTransactionTag(adConfiguration: adConfiguration1)
        
        let adConfiguration2 = OXMAdConfiguration()
//        adConfiguration2.domain = "another"
//        adConfiguration2.auid = "12345"
        adConfiguration2.adFormat = .display
        let tag2 = OXMTransactionTag(adConfiguration: adConfiguration2)
        
        XCTAssertNotEqual(tag1, tag2)
        XCTAssertFalse(tag1 === tag2)
        
//        adConfiguration1.auid = nil
//        adConfiguration1.pgid = "67890"
        let tag3 = OXMTransactionTag(adConfiguration: adConfiguration1)
        
//        adConfiguration2.auid = nil
//        adConfiguration2.pgid = "67890"
        let tag4 = OXMTransactionTag(adConfiguration: adConfiguration2)
        XCTAssertNotEqual(tag3, tag4)
        
//        adConfiguration1.auid = "12345"
        let tag5 = OXMTransactionTag(adConfiguration: adConfiguration1)
//        adConfiguration2.auid = "12345"
        let tag6 = OXMTransactionTag(adConfiguration: adConfiguration2)
        XCTAssertNotEqual(tag5, tag6)
        
//        adConfiguration2.domain = adConfiguration1.domain
//        adConfiguration2.auid = "another"
        XCTAssertNotEqual(tag5, OXMTransactionTag(adConfiguration: adConfiguration2))
//        adConfiguration2.auid = nil
        XCTAssertNotEqual(tag5, OXMTransactionTag(adConfiguration: adConfiguration2))
        
//        adConfiguration2.auid = adConfiguration1.auid
//        adConfiguration2.pgid = "another"
        XCTAssertNotEqual(tag5, OXMTransactionTag(adConfiguration: adConfiguration2))
//        adConfiguration2.pgid = nil
        XCTAssertNotEqual(tag5, OXMTransactionTag(adConfiguration: adConfiguration2))
        
//        adConfiguration2.pgid = adConfiguration1.pgid
        adConfiguration2.adFormat = .video
        XCTAssertNotEqual(tag5, OXMTransactionTag(adConfiguration: adConfiguration2))
    }
        
    func testNSCopying() {
        let initialAdConfiguration = OXMAdConfiguration()
//        initialAdConfiguration.domain = "test"
//        initialAdConfiguration.auid = "12345"
        let initilaTag = OXMTransactionTag(adConfiguration: initialAdConfiguration)
        
        let copiedTag = initilaTag.copy() as! OXMTransactionTag
        
        XCTAssertEqual(initilaTag, copiedTag)
        XCTAssertFalse(initilaTag === copiedTag)
    }
    
    func testCreateAdConfiguration() {
        let adConfiguration = OXMAdConfiguration()
//        adConfiguration.domain = "test"
//        adConfiguration.auid = "12345"
        let tag = OXMTransactionTag(adConfiguration: adConfiguration)
        
        let createdAdConfiguration = tag.createAdConfiguration()
        XCTAssertNotNil(createdAdConfiguration)
//        XCTAssertEqual(adConfiguration.auid, createdAdConfiguration.auid)
//        XCTAssertEqual(adConfiguration.domain, createdAdConfiguration.domain)
//        XCTAssertEqual(adConfiguration.pgid, createdAdConfiguration.pgid)
        XCTAssertEqual(adConfiguration.adFormat, createdAdConfiguration.adFormat)
    }
}
