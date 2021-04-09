//
//  OXANativeAdConfigurationTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXANativeAdConfigurationTest: XCTestCase {

    func testSetupConfig() {
        let desc = OXANativeAssetData(dataType: .desc)
        let nativeAdConfig = OXANativeAdConfiguration.init(assets:[desc])
        
        nativeAdConfig.context = .socialCentric
        nativeAdConfig.contextsubtype = .applicationStore
        nativeAdConfig.plcmttype = .feedGridListing
        nativeAdConfig.seq = 1
        
        let nativeMarkupObject = nativeAdConfig.markupRequestObject
        
        XCTAssertEqual(nativeMarkupObject.context?.intValue, OXANativeContextType.socialCentric.rawValue)
        XCTAssertEqual(nativeMarkupObject.contextsubtype?.intValue, OXANativeContextSubtype.applicationStore.rawValue)
        XCTAssertEqual(nativeMarkupObject.plcmttype?.intValue, OXANativePlacementType.feedGridListing.rawValue)
        XCTAssertEqual(nativeMarkupObject.seq?.intValue, 1)
        
        nativeAdConfig.context = .undefined
        nativeAdConfig.contextsubtype = .undefined
        nativeAdConfig.plcmttype = .undefined
        nativeAdConfig.seq = -1
        
        XCTAssertNil(nativeMarkupObject.context)
        XCTAssertNil(nativeMarkupObject.contextsubtype)
        XCTAssertNil(nativeMarkupObject.plcmttype)
        XCTAssertNil(nativeMarkupObject.seq)
    }
}
