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
import UIKit

/*!
 The banner custom event delegate. It is used to inform the ad server SDK events back to the PBM SDK.
 */
@objc public protocol BannerEventInteractionDelegate: NSObjectProtocol {

    /*!
     @abstract Call this when the ad server SDK is about to present a modal
     */
    func willPresentModal()

    /*!
     @abstract Call this when the ad server SDK dissmisses a modal
     */
    func didDismissModal()

    /*!
     @abstract Call this when the ad server SDK informs about app leave event as a result of user interaction.
     */
    func willLeaveApp()

    /*!
     @abstract Returns a view controller instance to be used by ad server SDK for showing modals
     @result a UIViewController instance for showing modals
     */
    var viewControllerForPresentingModal: UIViewController? { get }
}
