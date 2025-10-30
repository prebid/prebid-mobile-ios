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

/// A protocol that defines methods for receiving loading events related to ad display views.
/// This protocol is used to notify the delegate when an ad has successfully loaded or if an error occurs during loading.
@objc
public protocol DisplayViewLoadingDelegate: NSObjectProtocol {
    
    /// Notifies that the ad has successfully loaded in the display view.
    ///
    /// - Parameters:
    ///   - displayView: The `UIView` instance in which the ad has been loaded.
    @objc func displayViewDidLoadAd(_ displayView: UIView)
    
    /// Notifies that an error occurred during the ad loading process.
    ///
    /// - Parameters:
    ///   - displayView: The `UIView` instance where the ad was intended to load.
    ///   - error: An `Error` instance describing the issue that occurred during the ad loading.
    @objc func displayView(_ displayView: UIView, didFailWithError error: Error)
}
