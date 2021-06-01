//
//  PBMAppInfoParameterBuilderTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class PBMAppInfoParameterBuilderTest: XCTestCase {

    let parameterDict = ["foo": "bar"]
    let publisherName = "publisherName"
    var bidRequest: PBMORTBBidRequest!
    var mockBundle: MockBundle!
    var builder: PBMAppInfoParameterBuilder!
    var targeting: PrebidRenderingTargeting!

    override func setUp() {
        super.setUp()
        bidRequest = PBMORTBBidRequest()
        mockBundle = MockBundle()
        targeting = PrebidRenderingTargeting.shared
        targeting.publisherName = publisherName
        
        builder = PBMAppInfoParameterBuilder(bundle: mockBundle, targeting: targeting)
    }

    func testAddsAppInfoToORTBBidRequest() {
        builder.build(bidRequest)

        PBMAssertEq(bidRequest.app.bundle, mockBundle.mockBundleIdentifier)
        PBMAssertEq(bidRequest.app.name, mockBundle.mockBundleDisplayName)
        PBMAssertEq(bidRequest.app.publisher?.name, publisherName)
        
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

        PBMAssertEq(bidRequest.app.name, mockBundle.mockBundleName)
    }

    func testMissingBundleName() {
        mockBundle.mockBundleName = nil
        builder.build(bidRequest)

        PBMAssertEq(bidRequest.app.name, mockBundle.mockBundleDisplayName)
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
