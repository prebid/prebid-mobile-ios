//
//  OXADFPBannerTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloGAMEventHandlers

class OXADFPBannerTest: XCTestCase {
    
    private class DummyDelegate: NSObject, GADBannerViewDelegate {
    }
    private class DummyEventDelegate: NSObject, GADAppEventDelegate {
    }
    private class DummySizeDelegate: NSObject, GADAdSizeDelegate {
        func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
            // nop
        }
    }
    
    func testProperties() {
        XCTAssertTrue(OXADFPBanner.classesFound)
        
        let propTests: [BasePropTest<OXADFPBanner>] = [
            PropTest(keyPath: \.adUnitID, value: "144"),
            PropTest(keyPath: \.validAdSizes, value: [NSValueFromGADAdSize(kGADAdSizeBanner)]),
            PropTest(keyPath: \.rootViewController, value: UIViewController()),
            RefPropTest(keyPath: \.delegate, value: DummyDelegate()),
            RefPropTest(keyPath: \.appEventDelegate, value: DummyEventDelegate()),
            RefPropTest(keyPath: \.adSizeDelegate, value: DummySizeDelegate()),
            PropTest(keyPath: \.enableManualImpressions, value: true),
            PropTest(keyPath: \.adSize, value: kGADAdSizeBanner),
        ]
        
        let banner = OXADFPBanner()
        
        for nextTest in propTests {
            nextTest.run(object: banner)
        }
    }
    
}
