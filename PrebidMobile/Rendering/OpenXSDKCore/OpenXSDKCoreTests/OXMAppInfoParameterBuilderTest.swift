//
//  OXMAppInfoParameterBuilderTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class OXMAppInfoParameterBuilderTest: XCTestCase {

    let parameterDict = ["foo": "bar"]
    let publisherName = "publisherName"
    var bidRequest: OXMORTBBidRequest!
    var mockBundle: MockBundle!
    var builder: OXMAppInfoParameterBuilder!
    var targeting: OXATargeting!

    override func setUp() {
        super.setUp()
        bidRequest = OXMORTBBidRequest()
        mockBundle = MockBundle()
        targeting = OXATargeting.withDisabledLock
        targeting.publisherName = publisherName
        
        builder = OXMAppInfoParameterBuilder(bundle: mockBundle, targeting: targeting)
    }

    func testAddsAppInfoToORTBBidRequest() {
        builder.build(bidRequest)

        OXMAssertEq(bidRequest.app.bundle, mockBundle.mockBundleIdentifier)
        OXMAssertEq(bidRequest.app.name, mockBundle.mockBundleDisplayName)
        OXMAssertEq(bidRequest.app.publisher?.name, publisherName)
        
        XCTAssertNotEqual(bidRequest.app.name, mockBundle.mockBundleName)
    }

    func testMissingBundleIdentifier() {
        mockBundle.mockBundleIdentifier = nil
        builder.build(bidRequest)

        XCTAssertNil(bidRequest.app.bundle)
    }

    func testMissingBundleDisplayName() {
        mockBundle.mockBundleDisplayName = nil
        builder.build(bidRequest)

        OXMAssertEq(bidRequest.app.name, mockBundle.mockBundleName)
    }

    func testMissingBundleName() {
        mockBundle.mockBundleName = nil
        builder.build(bidRequest)

        OXMAssertEq(bidRequest.app.name, mockBundle.mockBundleDisplayName)
    }

    func testMissingAllBundleDisplayNameAndBundleName() {
        mockBundle.mockBundleDisplayName = nil
        mockBundle.mockBundleName = nil
        builder.build(bidRequest)

        XCTAssertNil(bidRequest.app.name)
    }

    func testMissingBundleInfoDictionary() {
        mockBundle.mockShouldNilInfoDictionary = true
        builder.build(bidRequest)

        XCTAssertNil(bidRequest.app.name)
    }
    
    func testMissingPublisherName() {
        targeting.publisherName = nil
        builder.build(bidRequest)

        XCTAssertNil(bidRequest.app.publisher?.name)
    }
}
