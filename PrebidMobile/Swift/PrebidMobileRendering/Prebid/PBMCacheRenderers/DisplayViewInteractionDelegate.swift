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

/// A protocol that defines methods for handling user interactions and lifecycle events related to ad display views.
@objc
public protocol DisplayViewInteractionDelegate: NSObjectProtocol {

    /// Tracks an impression for the specified display view.
    ///
    /// - Parameters:
    ///   - forDisplayView: The `UIView` instance associated with the ad impression.
    @objc func trackImpression(forDisplayView: UIView)
    
    /// Notifies that the user has left the app after interacting with the ad.
    ///
    /// - Parameters:
    ///   - displayView: The `UIView` instance associated with the ad interaction.
    @objc func didLeaveApp(from displayView: UIView)
    
    /// Notifies that a modal view is about to be presented from the specified display view.
    ///
    /// - Parameters:
    ///   - displayView: The `UIView` instance associated with the modal presentation.
    @objc func willPresentModal(from displayView: UIView)
    
    /// Notifies the delegate that a modal view has been dismissed.
    ///
    /// - Parameters:
    ///   - displayView: The `UIView` instance associated with the dismissed modal.
    @objc func didDismissModal(from displayView: UIView)
    
    /// Requests the `UIViewController` to be used for presenting modals from the specified display view.
    ///
    /// - Parameters:
    ///   - fromDisplayView: The `UIView` instance from which the modal is to be presented.
    @objc func viewControllerForModalPresentation(
        fromDisplayView: UIView
    ) -> UIViewController?
}
