//
//  OXADFPInterstitialTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloGAMEventHandlers

class OXADFPInterstitialTest: XCTestCase {
    
    private class DummyDelegate: NSObject, GADInterstitialDelegate {
    }
    private class DummyEventDelegate: NSObject, GADAppEventDelegate {
    }
    
    func testProperties() {
        XCTAssertTrue(OXADFPInterstitial.classesFound)
        
        let propTests: [BasePropTest<OXADFPInterstitial>] = [
            RefPropTest(keyPath: \.delegate, value: DummyDelegate()),
            RefPropTest(keyPath: \.appEventDelegate, value: DummyEventDelegate()),
        ]
        
        let interstitial = OXADFPInterstitial(adUnitID: "/21808260008/prebid_oxb_html_interstitial")
        
        XCTAssertFalse(interstitial.isReady)
        
        for nextTest in propTests {
            nextTest.run(object: interstitial)
        }
    }
}
