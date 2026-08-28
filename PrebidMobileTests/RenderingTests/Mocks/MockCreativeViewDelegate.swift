/*   Copyright 2018-2026 Prebid.org, Inc.

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

import StoreKit
@testable @_spi(PBMInternal) import PrebidMobile

class MockCreativeViewDelegate: NSObject, CreativeViewDelegate {
    
    var creativeClickthroughDidCloseHandler: ((AbstractCreative) -> Void)?
    func creativeClickthroughDidClose(_ creative: AbstractCreative) {
        creativeClickthroughDidCloseHandler?(creative)
    }

    func creativeDidComplete(_ creative: AbstractCreative) {}
    func creativeDidDisplay(_ creative: AbstractCreative) {}
    func creativeWasClicked(_ creative: AbstractCreative) {}
    func creativeViewWasClicked(_ creative: AbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: AbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: AbstractCreative) {}
    func creativeReadyToReimplant(_ creative: AbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: AbstractCreative) {}
    func creativeMraidDidExpand(_ creative: AbstractCreative) {}
}
