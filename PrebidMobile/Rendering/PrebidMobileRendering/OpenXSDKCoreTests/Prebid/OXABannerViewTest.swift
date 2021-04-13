//
//  OXABannerViewTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering


class OXABannerViewTest: XCTestCase {
    override func tearDown() {
        OXASDKConfiguration.resetSingleton()
        
        super.tearDown()
    }
    
    func testConfigSetup() {
        let testID = "auid"

        let primarySize = CGSize(width: 320, height: 50)
        
        let bannerView = OXABannerView(frame: CGRect(origin: .zero, size: primarySize), configId: testID, adSize: primarySize)
        let adUnitConfig = bannerView.adUnitConfig
        
        XCTAssertEqual(adUnitConfig.configId, testID)
        XCTAssertEqual(adUnitConfig.adSize?.cgSizeValue, primarySize)
        
        let moreSizes = [
            CGSize(width: 300, height: 250),
            CGSize(width: 728, height: 90),
        ]
        
        bannerView.additionalSizes = moreSizes.map(NSValue.init(cgSize:))
        
        XCTAssertEqual(adUnitConfig.additionalSizes?.count, moreSizes.count)
        for i in 0..<moreSizes.count {
            XCTAssertEqual(adUnitConfig.additionalSizes?[i].cgSizeValue, moreSizes[i])
        }
        
        let refreshInterval: TimeInterval = 40;
        
        bannerView.refreshInterval = refreshInterval
        XCTAssertEqual(adUnitConfig.refreshInterval, refreshInterval)
    }
    
    func testAccountErrorPropagation() {
        let testID = "auid"
        
        OXASDKConfiguration.singleton.accountID = ""
        let primarySize = CGSize(width: 320, height: 50)
        
        let bannerView = OXABannerView(frame: CGRect(origin: .zero, size: primarySize), configId: testID, adSize: primarySize)
        let exp = expectation(description: "loading callback called")
        let delegate = TestBannerDelegate(exp: exp)
        bannerView.delegate = delegate
        
        bannerView.loadAd()
        
        waitForExpectations(timeout: 3)
    }
    
    @objc private class TestBannerDelegate: NSObject, OXABannerViewDelegate {
        let exp: XCTestExpectation
        
        init(exp: XCTestExpectation) {
            self.exp = exp
        }
        
        func bannerViewPresentationController() -> UIViewController? {
            return nil
        }
        
        func bannerViewDidReceiveAd(_ bannerView: OXABannerView, adSize: CGSize) {
            XCTFail("Ad unexpectedly loaded successfully...")
            exp.fulfill()
        }
        
        func bannerView(_ bannerView: OXABannerView, didFailToReceiveAdWithError error: Error?) {
            XCTAssertEqual(error as NSError?, OXAError.invalidAccountId as NSError?)
            exp.fulfill()
        }
    }
    
}
