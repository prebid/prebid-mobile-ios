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

    @objc func callDelegate_didReceiveAd()
    @objc func callDelegate_didFailToReceiveAd(with error: Error?)
    @objc func callDelegate_willPresentAd()
    @objc func callDelegate_didDismissAd()
    @objc func callDelegate_willLeaveApplication()
    @objc func callDelegate_didClickAd()

    @objc func callEventHandler_isReady() -> Bool
    @objc func callEventHandler_setLoadingDelegate(_ loadingDelegate: NSObject?)
    @objc func callEventHandler_setInteractionDelegate()
    @objc func callEventHandler_requestAd(with bidResponse: BidResponse?)
    @objc func callEventHandler_show(from controller: UIViewController?)
    @objc func callEventHandler_trackImpression()
    
    @objc optional func callDelegate_rewardedAdUserDidEarnReward(reward: PrebidReward)
}
