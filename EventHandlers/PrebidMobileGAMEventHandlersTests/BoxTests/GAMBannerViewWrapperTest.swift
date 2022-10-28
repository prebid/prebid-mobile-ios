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
            PropTest(keyPath: \.validAdSizes, value: [NSValueFromGADAdSize(GADAdSizeBanner)]),
            PropTest(keyPath: \.rootViewController, value: UIViewController()),
            RefPropTest(keyPath: \.delegate, value: DummyDelegate()),
            RefPropTest(keyPath: \.appEventDelegate, value: DummyEventDelegate()),
            RefPropTest(keyPath: \.adSizeDelegate, value: DummySizeDelegate()),
            PropTest(keyPath: \.enableManualImpressions, value: true),
            PropTest(keyPath: \.adSize, value: GADAdSizeBanner),
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
