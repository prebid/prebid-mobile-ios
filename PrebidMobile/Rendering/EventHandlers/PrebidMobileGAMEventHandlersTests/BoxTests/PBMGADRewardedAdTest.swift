//
//  PBMGADRewardedAdTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileGAMEventHandlers

class PBMGADRewardedAdTest: XCTestCase {
    private class DummyDelegate: NSObject, GADRewardedAdDelegate {
        func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        }
    }
    private class DummyMetadataDelegate: NSObject, GADRewardedAdMetadataDelegate {
    }
    
    func testProperties() {
        XCTAssertTrue(PBMGADRewardedAd.classesFound)
        
        let propTests: [BasePropTest<PBMGADRewardedAd>] = [
            RefPropTest(keyPath: \.adMetadataDelegate, value: DummyMetadataDelegate()),
        ]
        
        let rewardedAd = PBMGADRewardedAd(adUnitID: "/21808260008/prebid_oxb_rewarded_video_test")
        
        XCTAssertFalse(rewardedAd.isReady)
        XCTAssertNil(rewardedAd.adMetadata)
        XCTAssertNil(rewardedAd.reward)
        
        for nextTest in propTests {
            nextTest.run(object: rewardedAd)
        }
    }
}
