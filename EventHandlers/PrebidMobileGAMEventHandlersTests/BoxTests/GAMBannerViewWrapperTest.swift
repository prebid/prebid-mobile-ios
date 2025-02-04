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
import GoogleMobileAds
@testable import PrebidMobileGAMEventHandlers

class GAMBannerViewWrapperTest: XCTestCase {
    
    private class DummyDelegate: NSObject, GoogleMobileAds.BannerViewDelegate {}
    
    private class DummyEventDelegate: NSObject, GoogleMobileAds.AppEventDelegate {}
    
    private class DummySizeDelegate: NSObject, GoogleMobileAds.AdSizeDelegate {
        func adView(_ bannerView: GoogleMobileAds.BannerView, willChangeAdSizeTo size: GoogleMobileAds.AdSize) {
            // nop
        }
    }
    
    func testProperties() {        
        let propTests: [BasePropTest<GAMBannerViewWrapper>] = [
            PropTest(keyPath: \.adUnitID, value: "144"),
            PropTest(keyPath: \.validAdSizes, value: [GoogleMobileAds.nsValue(for: GoogleMobileAds.AdSizeBanner)]),
            PropTest(keyPath: \.rootViewController, value: UIViewController()),
            RefPropTest(keyPath: \.delegate, value: DummyDelegate()),
            RefPropTest(keyPath: \.appEventDelegate, value: DummyEventDelegate()),
            RefPropTest(keyPath: \.adSizeDelegate, value: DummySizeDelegate()),
            PropTest(keyPath: \.enableManualImpressions, value: true),
            PropTest(keyPath: \.adSize, value: GoogleMobileAds.AdSizeBanner),
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
