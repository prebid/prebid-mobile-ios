/*   Copyright 2018-2021 Prebid.org, Inc.
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
  http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

import XCTest

@testable import PrebidMobile

class MockBannerView: BannerView {
    override var lastBidResponse: BidResponse? {
        return WinningBidResponseFabricator.makeWinningBidResponse(bidPrice: 0.85)
    }
}

class PBMBannerViewTest: XCTestCase {
    override func tearDown() {
        Prebid.reset()
        
        super.tearDown()
    }
    
    func testConfigSetup() {
        let testID = "auid"
        
        let primarySize = CGSize(width: 320, height: 50)
        
        let bannerView = MockBannerView(frame: CGRect(origin: .zero, size: primarySize), configID: testID, adSize: primarySize, eventHandler: BannerEventHandlerStandalone())
        let adUnitConfig = bannerView.adUnitConfig
        
        XCTAssertEqual(adUnitConfig.configId, testID)
        XCTAssertEqual(adUnitConfig.adSize, primarySize)
        
        let moreSizes = [
            CGSize(width: 300, height: 250),
            CGSize(width: 728, height: 90),
        ]
        
        bannerView.additionalSizes = moreSizes
        
        XCTAssertEqual(adUnitConfig.additionalSizes?.count, moreSizes.count)
        for i in 0..<moreSizes.count {
            XCTAssertEqual(adUnitConfig.additionalSizes?[i], moreSizes[i])
        }
        
        let refreshInterval: TimeInterval = 40;
        
        bannerView.refreshInterval = refreshInterval
        XCTAssertEqual(adUnitConfig.refreshInterval, refreshInterval)
    }
    
    func testAccountErrorPropagation() {
        let testID = "auid"
        
        Prebid.shared.prebidServerAccountId = ""
        let primarySize = CGSize(width: 320, height: 50)
        
        let bannerView = MockBannerView(frame: CGRect(origin: .zero, size: primarySize), configID: testID, adSize: primarySize, eventHandler: BannerEventHandlerStandalone())
        let exp = expectation(description: "loading callback called")
        let delegate = TestBannerDelegate(exp: exp)
        bannerView.delegate = delegate
        
        bannerView.loadAd()
        
        waitForExpectations(timeout: 3)
    }
    
    @objc private class TestBannerDelegate: NSObject, BannerViewDelegate {
        let exp: XCTestExpectation
        
        init(exp: XCTestExpectation) {
            self.exp = exp
        }
        
        func bannerViewPresentationController() -> UIViewController? {
            return nil
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWith error: Error) {
            XCTAssertEqual(error as NSError?, PBMError.prebidInvalidAccountId as NSError?)
            XCTAssertNotNil(bannerView.lastBidResponse)
            exp.fulfill()
        }
        
        func bannerView(_ bannerView: BannerView, didReceiveAdWithAdSize adSize: CGSize) {
            XCTFail("Ad unexpectedly loaded successfully...")
            exp.fulfill()
        }
    }
}
