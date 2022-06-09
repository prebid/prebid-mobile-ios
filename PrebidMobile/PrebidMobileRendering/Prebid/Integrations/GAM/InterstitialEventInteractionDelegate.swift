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

import Foundation

@objc public protocol InterstitialEventInteractionDelegate: NSObjectProtocol {
    
    /*!
     @abstract Call this when the ad server SDK is about to present a modal
     */
    @objc func willPresentAd()

    /*!
     @abstract Call this when the ad server SDK dissmisses a modal
     */
    @objc func didDismissAd()

    /*!
     @abstract Call this when the ad server SDK informs about app leave event as a result of user interaction.
     */
    @objc func willLeaveApp()

    /*!
     @abstract Call this when the ad server SDK informs about click event as a result of user interaction.
     */
    @objc func didClickAd()
}
