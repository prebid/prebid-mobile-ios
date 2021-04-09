//
//  OXMUserConsentParameterBuilderTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXMUserConsentParameterBuilderTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {        
        let builder = OXMUserConsentParameterBuilder()
        XCTAssertNotNil(builder)
    }

    func testBuilderNotSubjectToGDPR() {
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.mock_subjectToGDPR = false
        mockUserDefaults.mock_consentString = "consentstring"

        let mockUserConsentManager = OXMUserConsentDataManager(userDefaults: mockUserDefaults)
        let builder = OXMUserConsentParameterBuilder(userConsentManager: mockUserConsentManager)

        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)

        XCTAssertEqual(bidRequest.regs.ext?["gdpr"] as? Int, 0)
        XCTAssertEqual(bidRequest.user.ext?["consent"] as? String, "consentstring")
    }

    func testBuilderSubjectToGDPR() {
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.mock_subjectToGDPR = true
        mockUserDefaults.mock_consentString = "differentconsentstring"

        let mockUserConsentManager = OXMUserConsentDataManager(userDefaults: mockUserDefaults)
        let builder = OXMUserConsentParameterBuilder(userConsentManager: mockUserConsentManager)

        let bidRequest = OXMORTBBidRequest()
        builder.build(bidRequest)

        XCTAssertEqual(bidRequest.regs.ext?["gdpr"] as? Int, 1)
        XCTAssertEqual(bidRequest.user.ext?["consent"] as? String, "differentconsentstring")
    }

}
