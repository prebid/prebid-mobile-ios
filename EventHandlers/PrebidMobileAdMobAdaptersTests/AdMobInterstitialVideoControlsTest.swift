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

import XCTest
import GoogleMobileAds
@testable @_spi(PBMInternal) import PrebidMobile
@testable import PrebidMobileAdMobAdapters

// For a video bid, the mediation ad unit hands its own `VideoControlsConfiguration` to the adapter,
// and the adapter renders with that instance. The bid's server-side values have to go into the
// controller's per-bid copy: written into that instance, they would change the ad unit's `isMuted`
// and every later ad from the same ad unit.
final class AdMobInterstitialVideoControlsTest: XCTestCase {

    private let serverParameter = "{\"hb_pb\":\"0.10\"}"
    private let targetingInfo = ["hb_pb": "0.10"]

    func testVideoInterstitialAdapterKeepsTheAdUnitIsMuted() {
        let mediationDelegate = AdMobMediationInterstitialUtils(gadRequest: GoogleMobileAds.Request())
        let adUnit = MediationInterstitialAdUnit(configId: "configId", mediationDelegate: mediationDelegate)
        adUnit.isMuted = true
        setUpVideoBid(for: adUnit, mediationDelegate: mediationDelegate, serverIsMuted: false)

        let adapter = PrebidAdMobVideoInterstitialAdapter()
        adapter.loadInterstitial(
            for: StubInterstitialAdConfiguration(
                credentials: StubCredentials(settings: ["parameter": serverParameter]),
                extras: mediationDelegate.gadRequest.adNetworkExtras(for: GoogleMobileAds.CustomEventExtras.self)
            )
        ) { _, error in
            XCTFail("The load was not expected to finish: \(String(describing: error))")
            return nil
        }

        let controller = adapter.interstitialController as? InterstitialController
        XCTAssertEqual(controller?.renderingConfiguration?.adConfiguration.videoControlsConfig.isMuted, false,
                       "ismuted=0 applies to this ad")
        XCTAssertTrue(adUnit.isMuted, "The ad unit keeps the app's value")
    }

    func testRewardedAdapterKeepsTheAdUnitIsMuted() {
        let mediationDelegate = AdMobMediationRewardedUtils(gadRequest: GoogleMobileAds.Request())
        let adUnit = MediationRewardedAdUnit(configId: "configId", mediationDelegate: mediationDelegate)
        adUnit.isMuted = false
        setUpVideoBid(for: adUnit, mediationDelegate: mediationDelegate, serverIsMuted: true)

        let adapter = PrebidAdMobRewardedAdapter()
        adapter.loadRewardedAd(
            for: StubRewardedAdConfiguration(
                credentials: StubCredentials(settings: ["parameter": serverParameter]),
                extras: mediationDelegate.gadRequest.adNetworkExtras(for: GoogleMobileAds.CustomEventExtras.self)
            )
        ) { _, error in
            XCTFail("The load was not expected to finish: \(String(describing: error))")
            return nil
        }

        let controller = adapter.interstitialController as? InterstitialController
        XCTAssertEqual(controller?.renderingConfiguration?.adConfiguration.videoControlsConfig.isMuted, true,
                       "ismuted=1 applies to this ad")
        XCTAssertFalse(adUnit.isMuted, "The ad unit keeps the app's value")
    }

    // MARK: - Helpers

    /// Hands over a winning video bid the way `MediationBaseInterstitialAdUnit` does after an auction.
    /// The bid has no markup, so the controller stops before rendering anything.
    private func setUpVideoBid(
        for adUnit: MediationBaseInterstitialAdUnit,
        mediationDelegate: PrebidMediationDelegate,
        serverIsMuted: Bool
    ) {
        let serverControls = ORTBAdConfiguration()
        serverControls.isMuted = NSNumber(value: serverIsMuted)
        let passthrough = ORTBExtPrebidPassthrough()
        passthrough.type = "prebidmobilesdk"
        passthrough.adConfiguration = serverControls

        let rawBid = ORTBBid<ORTBBidExt>(bidID: "bid-id", impid: "imp-id", price: 0.1)
        rawBid.ext = .init()
        rawBid.ext?.prebid = .init()
        rawBid.ext?.prebid?.type = "video"
        rawBid.ext?.prebid?.passthrough = [passthrough]

        let isSetUp = mediationDelegate.setUpAdObject(with: [
            PBMMediationConfigIdKey: adUnit.configId,
            PBMMediationTargetingInfoKey: targetingInfo,
            PBMMediationAdUnitBidKey: Bid(bid: rawBid),
            PBMMediationVideoAdConfiguration: adUnit.adUnitConfig.adConfiguration.videoControlsConfig,
            PBMMediationVideoParameters: adUnit.adUnitConfig.adConfiguration.videoParameters
        ])
        XCTAssertTrue(isSetUp)
    }
}

private final class StubCredentials: GoogleMobileAds.MediationCredentials {
    private let stubSettings: [String: Any]

    init(settings: [String: Any]) {
        stubSettings = settings
        super.init()
    }

    override var settings: [String: Any] {
        stubSettings
    }
}

private final class StubInterstitialAdConfiguration: GoogleMobileAds.MediationInterstitialAdConfiguration {
    private let stubCredentials: GoogleMobileAds.MediationCredentials
    private let stubExtras: GoogleMobileAds.AdNetworkExtras?

    init(credentials: GoogleMobileAds.MediationCredentials, extras: GoogleMobileAds.AdNetworkExtras?) {
        stubCredentials = credentials
        stubExtras = extras
        super.init()
    }

    override var credentials: GoogleMobileAds.MediationCredentials {
        stubCredentials
    }

    override var extras: GoogleMobileAds.AdNetworkExtras? {
        stubExtras
    }
}

private final class StubRewardedAdConfiguration: GoogleMobileAds.MediationRewardedAdConfiguration {
    private let stubCredentials: GoogleMobileAds.MediationCredentials
    private let stubExtras: GoogleMobileAds.AdNetworkExtras?

    init(credentials: GoogleMobileAds.MediationCredentials, extras: GoogleMobileAds.AdNetworkExtras?) {
        stubCredentials = credentials
        stubExtras = extras
        super.init()
    }

    override var credentials: GoogleMobileAds.MediationCredentials {
        stubCredentials
    }

    override var extras: GoogleMobileAds.AdNetworkExtras? {
        stubExtras
    }
}
