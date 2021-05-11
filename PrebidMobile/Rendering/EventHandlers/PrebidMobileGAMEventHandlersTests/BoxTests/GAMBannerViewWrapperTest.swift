//
//  PBMDFPBannerTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
import GoogleMobileAds
@testable import PrebidMobileGAMEventHandlers

class GAMBannerViewWrapperTest: XCTestCase {
    
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
        let propTests: [BasePropTest<GAMBannerViewWrapper>] = [
            PropTest(keyPath: \.adUnitID, value: "144"),
            PropTest(keyPath: \.validAdSizes, value: [NSValueFromGADAdSize(kGADAdSizeBanner)]),
            PropTest(keyPath: \.rootViewController, value: UIViewController()),
            RefPropTest(keyPath: \.delegate, value: DummyDelegate()),
            RefPropTest(keyPath: \.appEventDelegate, value: DummyEventDelegate()),
            RefPropTest(keyPath: \.adSizeDelegate, value: DummySizeDelegate()),
            PropTest(keyPath: \.enableManualImpressions, value: true),
            PropTest(keyPath: \.adSize, value: kGADAdSizeBanner),
        ]
        
        guard let banner = GAMBannerViewWrapper() else {
            XCTFail()
            return
        }
        
        for nextTest in propTests {
            nextTest.run(object: banner)
        }
    }
    
}
