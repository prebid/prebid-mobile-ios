/*   Copyright 2018-2026 Prebid.org, Inc.

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

fileprivate let storedImpDisplayBanner = "prebid-demo-banner-320-50"

class InAppDisplayBannerExtendedIdProviderViewController: BannerBaseViewController, BannerViewDelegate {

    // Prebid
    private var prebidBannerView: BannerView!
    private let sampleIdProvider = SampleExtendedIdProvider()

    override func loadView() {
        super.loadView()

        createAd()
    }

    deinit {
        // Unregister the provider when its IDs should no longer be sent
        Prebid.unregister(sampleIdProvider, as: .extendedIds)
    }

    func createAd() {
        // 1. Register the extended ID provider. Its IDs are added to every bid request while it is
        // registered, so an app usually registers its providers once, after initializing the SDK.
        // This example registers it only while the screen is shown.
        Prebid.register(sampleIdProvider, as: .extendedIds)

        // The EIDs the SDK adds to bid requests: the IDs set through Targeting, then SharedID if it is
        // enabled, then the IDs of each registered provider
        let sources = Targeting.shared.getExtendedIds().map { $0.source }
        PrebidDemoLogger.shared.info("EID sources added to bid requests: \(sources, privacy: .public)")

        // 2. Create a BannerView
        prebidBannerView = BannerView(
            frame: CGRect(origin: .zero, size: adSize),
            configID: storedImpDisplayBanner,
            adSize: adSize
        )

        // 3. Configure the BannerView
        prebidBannerView.delegate = self
        prebidBannerView.adFormats = [.banner]
        prebidBannerView.videoParameters.placement = .InBanner

        // Add Prebid banner view to the app UI
        bannerView.addSubview(prebidBannerView)

        // 4. Load the banner ad
        prebidBannerView.loadAd()
    }

    // MARK: - BannerViewDelegate

    func bannerViewPresentationController() -> UIViewController? {
        self
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWith error: Error) {
        PrebidDemoLogger.shared.error("Banner view did fail to receive ad with error: \(error)")
    }
}
