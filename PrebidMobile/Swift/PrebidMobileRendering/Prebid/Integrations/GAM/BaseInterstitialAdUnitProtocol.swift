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

import UIKit

@objc
protocol BaseInterstitialAdUnitProtocol: NSObjectProtocol {

    @objc func interstitialControllerDidCloseAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol)

    func callDelegate_didReceiveAd()
    func callDelegate_didFailToReceiveAd(with error: Error?)
    func callDelegate_willPresentAd()
    func callDelegate_didDismissAd()
    func callDelegate_willLeaveApplication()
    func callDelegate_didClickAd()

    func callEventHandler_isReady() -> Bool
    func callEventHandler_setLoadingDelegate(_ loadingDelegate: InterstitialEventLoadingDelegate?)
    func callEventHandler_setInteractionDelegate()
    func callEventHandler_requestAd(with bidResponse: BidResponse?)
    func callEventHandler_show(from controller: UIViewController?)
    func callEventHandler_trackImpression()
    
    @objc optional func callDelegate_adDidExpire()
    @objc optional func callDelegate_rewardedAdUserDidEarnReward(reward: PrebidReward)
}
