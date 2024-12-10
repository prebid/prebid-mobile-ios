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

/// A protocol that defines the interface for controlling and interacting with interstitial ads.
/// This protocol allows loading and displaying interstitial ads, as well as managing interactions with them.
@objc
public protocol PrebidMobileInterstitialControllerProtocol: NSObjectProtocol {
    
    /// Loads the ad content for the interstitial.
    /// - Important: This method is expected to call the `loadingDelegate` once the ad is successfully loaded or if any error occurred.
    func loadAd()
    
    /// Displays the interstitial ad.
    func show()
}
