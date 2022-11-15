/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

import UIKit
import PrebidMobile
import PrebidMobileMAXAdapters
import AppLovinSDK

fileprivate let storedResponseDisplayBanner = "response-prebid-banner-320-50"
fileprivate let storedImpDisplayBanner = "imp-prebid-banner-320-50"
fileprivate let maxAdUnitBannerRendering = "5419948894cdf762"

class MAXDisplayBannerViewController: BannerBaseViewController, MAAdViewAdDelegate {
    
    // Prebid
    private var maxAdUnit: MediationBannerAdUnit!
    private var maxMediationDelegate: MAXMediationBannerUtils!
    
    // MAX
    private var maxAdBannerView: MAAdView!

    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseDisplayBanner
        createAd()
    }

    func createAd() {
        maxAdBannerView = MAAdView(adUnitIdentifier: maxAdUnitBannerRendering)
        maxAdBannerView.frame = CGRect(origin: .zero, size: adSize)
        maxAdBannerView.delegate = self
        maxAdBannerView.isHidden = false
        bannerView.addSubview(maxAdBannerView)
        maxMediationDelegate = MAXMediationBannerUtils(adView: maxAdBannerView)
        maxAdUnit = MediationBannerAdUnit(configID: storedImpDisplayBanner, size: adSize, mediationDelegate: maxMediationDelegate)
        maxAdUnit.fetchDemand { [weak self] result in
            PrebidDemoLogger.shared.info("Prebid demand fetch result \(result.name())")
            self?.maxAdBannerView.loadAd()
        }
    }
    
    // MARK: - MAAdViewAdDelegate

    func didLoad(_ ad: MAAd) {}

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        PrebidDemoLogger.shared.error("\(error.message)")

        let nsError = NSError(domain: "MAX", code: error.code.rawValue, userInfo: [NSLocalizedDescriptionKey: error.message])
        maxAdUnit?.adObjectDidFailToLoadAd(adObject: maxAdBannerView!, with: nsError)
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        PrebidDemoLogger.shared.error("\(error.message)")

        let nsError = NSError(domain: "MAX", code: error.code.rawValue, userInfo: [NSLocalizedDescriptionKey: error.message])
        maxAdUnit?.adObjectDidFailToLoadAd(adObject: maxAdBannerView!, with: nsError)
    }

    func didDisplay(_ ad: MAAd) {}

    func didHide(_ ad: MAAd) {}

    func didExpand(_ ad: MAAd) {}

    func didCollapse(_ ad: MAAd) {}

    func didClick(_ ad: MAAd) {}
}
