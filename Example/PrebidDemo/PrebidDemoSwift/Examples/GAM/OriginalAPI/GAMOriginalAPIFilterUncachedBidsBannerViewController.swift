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
import GoogleMobileAds

fileprivate let storedImpDisplayBanner = "prebid-demo-banner-320-50"
fileprivate let gamAdUnitDisplayBannerOriginal = "/21808260008/prebid_demo_app_original_api_banner"

/// Demonstrates `Prebid.shared.filterOutUncachedBids` with the Original API.
///
/// When enabled, the SDK drops bids that Prebid Server failed to cache, so the ad server never
/// receives targeting for a bid whose creative could not be fetched from Prebid Cache. There are
/// two outcomes worth handling:
///
/// 1. Some cached demand survived. `resultCode` is `.prebidDemandFetchSuccess` and the ad request
///    proceeds as usual. If the bid Prebid Server designated as the winner was the one dropped, a
///    lower-priced cached bid is promoted in its place and `BidInfo.topBidFiltered` is `true`.
///    That is still a success: the ad serves, only the yield is lower. Keep loading the ad and
///    track the flag if you want to measure the impact.
/// 2. Every returned bid failed to cache. `resultCode` is `.prebidDemandNoCachedBids` and no
///    Prebid targeting is attached, so the request falls through to the ad server's own demand.
///
/// Note this uses `PrebidAdUnit`, which reports a full `BidInfo` while still attaching targeting
/// keywords to the ad object. `BannerAdUnit.fetchDemand(adObject:completion:)` reports only a
/// `ResultCode`, so it cannot surface `topBidFiltered`.
class GAMOriginalAPIFilterUncachedBidsBannerViewController:
    BannerBaseViewController,
    GoogleMobileAds.BannerViewDelegate {

    // Prebid
    private var adUnit: PrebidAdUnit!

    // GAM
    private var gamBanner: AdManagerBannerView!

    override func loadView() {
        super.loadView()

        createAd()
    }

    deinit {
        // The setting is global, so restore it when leaving the example.
        Prebid.shared.filterOutUncachedBids = false
    }

    func createAd() {
        // 1. Ignore bids Prebid Server could not cache. Original API only: the Rendering API
        // renders creatives from the bid markup and never fetches them from Prebid Cache.
        Prebid.shared.filterOutUncachedBids = true

        // 2. Setup a PrebidAdUnit
        adUnit = PrebidAdUnit(configId: storedImpDisplayBanner)
        adUnit.setAutoRefreshMillis(time: 30_000)

        // 3. Configure the banner parameters
        let bannerParameters = BannerParameters()
        bannerParameters.api = [Signals.Api.MRAID_2]
        bannerParameters.adSizes = [adSize]

        let prebidRequest = PrebidRequest(bannerParameters: bannerParameters)

        // 4. Create a AdManagerBannerView
        gamBanner = AdManagerBannerView(adSize: adSizeFor(cgSize: adSize))
        gamBanner.adUnitID = gamAdUnitDisplayBannerOriginal
        gamBanner.rootViewController = self
        gamBanner.delegate = self

        // Add GMA SDK banner view to the app UI
        bannerView?.addSubview(gamBanner)

        // 5. Make a bid request
        let gamRequest = AdManagerRequest()
        adUnit.fetchDemand(adObject: gamRequest, request: prebidRequest) { [weak self] bidInfo in
            PrebidDemoLogger.shared.info("Prebid demand fetch for GAM \(bidInfo.resultCode.name())")

            switch bidInfo.resultCode {
            case .prebidDemandFetchSuccess:
                // Cached demand is attached to the request. If the top bid was the one dropped,
                // a cheaper cached bid took its place, so the ad still serves.
                if bidInfo.topBidFiltered {
                    PrebidDemoLogger.shared.info(
                        "Top bid was dropped for a failed cache entry; a lower-priced cached bid was promoted."
                    )
                }
            case .prebidDemandNoCachedBids:
                // Prebid Server returned bids but none of them were cached, so none of them
                // could have rendered. No Prebid targeting is attached to the request.
                PrebidDemoLogger.shared.error("No bid returned by Prebid Server was cached.")
            default:
                PrebidDemoLogger.shared.error("Prebid demand fetch failed: \(bidInfo.resultCode.name())")
            }

            // 6. Load the GAM ad. The request is made in every case: without Prebid targeting it
            // simply falls through to the ad server's own demand.
            self?.gamBanner.load(gamRequest)
        }
    }

    // MARK: - GADBannerViewDelegate

    func bannerViewDidReceiveAd(_ bannerView: GoogleMobileAds.BannerView) {
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { size in
            guard let bannerView = bannerView as? AdManagerBannerView else { return }
            bannerView.resize(adSizeFor(cgSize: size))
        }, failure: { (error) in
            PrebidDemoLogger.shared.error("Error occuring during searching for Prebid creative size: \(error)")
        })
    }

    func bannerView(
        _ bannerView: GoogleMobileAds.BannerView,
        didFailToReceiveAdWithError error: Error
    ) {
        PrebidDemoLogger.shared.error("GAM did fail to receive ad with error: \(error)")
    }
}
