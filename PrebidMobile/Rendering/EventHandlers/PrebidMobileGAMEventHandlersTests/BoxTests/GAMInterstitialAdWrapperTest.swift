//
//  PBMDFPInterstitialTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
import GoogleMobileAds
@testable import PrebidMobileGAMEventHandlers

class GAMInterstitialAdWrapperTest: XCTestCase {
    
    private class DummyDelegate: NSObject, GADFullScreenContentDelegate {
    }
    
    private class DummyEventDelegate: NSObject, GADAppEventDelegate {
    }
    
    func testProperties() {
        let propTests: [BasePropTest<GAMInterstitialAdWrapper>] = [
            RefProxyPropTest(keyPath: \.fullScreenContentDelegate, value: DummyDelegate()),
            RefProxyPropTest(keyPath: \.appEventDelegate, value: DummyEventDelegate()),
        ]
        
        guard let interstitial = GAMInterstitialAdWrapper(adUnitID: "/21808260008/prebid_oxb_html_interstitial") else {
            XCTFail()
            return
        }
                
        for nextTest in propTests {
            nextTest.run(object: interstitial)
        }
    }
}
