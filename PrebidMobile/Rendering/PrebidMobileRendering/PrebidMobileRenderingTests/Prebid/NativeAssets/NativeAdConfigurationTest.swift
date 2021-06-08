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
        
        nativeAdConfig.context = NativeContextType.socialCentric.rawValue
        nativeAdConfig.contextsubtype = NativeContextSubtype.applicationStore.rawValue
        nativeAdConfig.plcmttype = NativePlacementType.feedGridListing.rawValue
        nativeAdConfig.seq = 1
        
        let nativeMarkupObject = nativeAdConfig.markupRequestObject
        
        XCTAssertEqual(nativeMarkupObject.context, NativeContextType.socialCentric.rawValue)
        XCTAssertEqual(nativeMarkupObject.contextsubtype, NativeContextSubtype.applicationStore.rawValue)
        XCTAssertEqual(nativeMarkupObject.plcmttype, NativePlacementType.feedGridListing.rawValue)
        XCTAssertEqual(nativeMarkupObject.seq, 1)
        
        nativeAdConfig.context = NativeContextType.undefined.rawValue
        nativeAdConfig.contextsubtype = NativeContextSubtype.undefined.rawValue
        nativeAdConfig.plcmttype = NativePlacementType.undefined.rawValue
        nativeAdConfig.seq = -1
        
        XCTAssertNil(nativeMarkupObject.context)
        XCTAssertNil(nativeMarkupObject.contextsubtype)
        XCTAssertNil(nativeMarkupObject.plcmttype)
        XCTAssertNil(nativeMarkupObject.seq)
    }
}
