//
//  OXAGADRewardedAdTest.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloGAMEventHandlers

class OXAGADRewardedAdTest: XCTestCase {
    private class DummyDelegate: NSObject, GADRewardedAdDelegate {
        func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        }
    }
    private class DummyMetadataDelegate: NSObject, GADRewardedAdMetadataDelegate {
    }
    
    func testProperties() {
        XCTAssertTrue(OXAGADRewardedAd.classesFound)
        
        let propTests: [BasePropTest<OXAGADRewardedAd>] = [
            RefPropTest(keyPath: \.adMetadataDelegate, value: DummyMetadataDelegate()),
        ]
        
        let rewardedAd = OXAGADRewardedAd(adUnitID: "/21808260008/prebid_oxb_rewarded_video_test")
        
        XCTAssertFalse(rewardedAd.isReady)
        XCTAssertNil(rewardedAd.adMetadata)
        XCTAssertNil(rewardedAd.reward)
        
        for nextTest in propTests {
            nextTest.run(object: rewardedAd)
        }
    }
}
