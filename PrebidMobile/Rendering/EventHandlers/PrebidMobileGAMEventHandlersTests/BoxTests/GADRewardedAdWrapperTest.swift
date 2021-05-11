//
//  PBMGADRewardedAdTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
import GoogleMobileAds
@testable import PrebidMobileGAMEventHandlers

class GADRewardedAdWrapperTest: XCTestCase {
    
    private class DummyDelegate: NSObject, GADFullScreenContentDelegate {
        func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        }
    }
    
    private class DummyMetadataDelegate: NSObject, GADAdMetadataDelegate {
        func adMetadataDidChange(_ ad: GADAdMetadataProvider) {
            
        }
        
    }
    
    func testProperties() {        
        let propTests: [BasePropTest<GADRewardedAdWrapper>] = [
            RefProxyPropTest(keyPath: \.adMetadataDelegate, value: DummyMetadataDelegate()),
        ]
        
        guard let rewardedAd = GADRewardedAdWrapper(adUnitID: "/21808260008/prebid_oxb_rewarded_video_test") else {
            XCTFail()
            return
        }
        
        XCTAssertNil(rewardedAd.adMetadata)
        XCTAssertNil(rewardedAd.reward)
        
        for nextTest in propTests {
            nextTest.run(object: rewardedAd)
        }
    }
}
