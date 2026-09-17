/*   Copyright 2018-2021 Prebid.org, Inc.

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
import UIKit

@testable @_spi(PBMInternal) import PrebidMobile

class InterstitialExpirationLoadingDelegate: NSObject, InterstitialControllerLoadingDelegate {
    let expirationExpectation: XCTestExpectation
    var onExpire: ((PrebidMobileInterstitialControllerProtocol) -> Void)?

    init(expirationExpectation: XCTestExpectation) {
        self.expirationExpectation = expirationExpectation
    }

    func interstitialControllerDidLoadAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}

    func interstitialController(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol,
        didFailWithError error: Error
    ) {}

    func interstitialControllerDidExpire(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        onExpire?(interstitialController)
        expirationExpectation.fulfill()
    }
}

class DisplayViewExpirationDelegate: NSObject, DisplayViewLoadingDelegate {
    let expirationExpectation: XCTestExpectation
    var onExpire: ((UIView) -> Void)?

    init(expirationExpectation: XCTestExpectation) {
        self.expirationExpectation = expirationExpectation
    }

    func displayViewDidLoadAd(_ displayView: UIView) {}

    func displayView(_ displayView: UIView, didFailWithError error: Error) {}

    func displayViewDidExpire(_ displayView: UIView) {
        onExpire?(displayView)
        expirationExpectation.fulfill()
    }
}

class TestAdViewManager: NSObject, AdViewManager {
    var adConfiguration = AdConfiguration()
    var modalManager = ModalManager()
    weak var adViewManagerDelegate: AdViewManagerDelegate?
    var autoDisplayOnLoad = false
    var isCreativeOpened = false
    var isMuted = false
    var showCalled = false

    required init(connection: PrebidServerConnectionProtocol, modalManagerDelegate: ModalManagerDelegate?) {}
    override init() {}

    func revenueForNextCreative() -> String? { nil }
    func isAbleToShowCurrentCreative() -> Bool { true }
    func show() { showCalled = true }
    func pause() {}
    func resume() {}
    func mute() {}
    func unmute() {}
    func handleExternalTransaction(_ transaction: Transaction) {}

    #if DEBUG
    weak var currentCreative: AbstractCreative?
    var externalTransaction: Transaction?
    func setupCreative(_ creative: AbstractCreative) {}
    func setupCreative(_ creative: AbstractCreative, withThread thread: ThreadProtocol) {}
    #endif

    func creativeDidComplete(_ creative: AbstractCreative) {}
    func creativeDidDisplay(_ creative: AbstractCreative) {}
    func creativeWasClicked(_ creative: AbstractCreative) {}
    func creativeViewWasClicked(_ creative: AbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: AbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: AbstractCreative) {}
    func creativeReadyToReimplant(_ creative: AbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: AbstractCreative) {}
    func creativeMraidDidExpand(_ creative: AbstractCreative) {}
}
