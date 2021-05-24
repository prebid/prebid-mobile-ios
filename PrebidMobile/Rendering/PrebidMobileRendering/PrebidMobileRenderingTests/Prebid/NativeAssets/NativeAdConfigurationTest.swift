//
//  NativeAdConfigurationTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class NativeAdConfigurationTest: XCTestCase {

    func testSetupConfig() {
        let desc = NativeAssetData(dataType: .desc)
        let nativeAdConfig = NativeAdConfiguration.init(assets:[desc])
        
        nativeAdConfig.context = .socialCentric
        nativeAdConfig.contextsubtype = .applicationStore
        nativeAdConfig.plcmttype = .feedGridListing
        nativeAdConfig.seq = 1
        
        let nativeMarkupObject = nativeAdConfig.markupRequestObject
        
        XCTAssertEqual(nativeMarkupObject.context?.intValue, PBMNativeContextType.socialCentric.rawValue)
        XCTAssertEqual(nativeMarkupObject.contextsubtype?.intValue, PBMNativeContextSubtype.applicationStore.rawValue)
        XCTAssertEqual(nativeMarkupObject.plcmttype?.intValue, PBMNativePlacementType.feedGridListing.rawValue)
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
