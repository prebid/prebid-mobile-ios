/*   Copyright 2019-2020 Prebid.org, Inc.

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

/// A protocol for handling events related to native ads.
///
/// This protocol defines optional methods that can be implemented to handle various events associated with native ads, such as expiration, clicks, and impressions. Implementing this protocol allows for custom handling of these events within the native ad lifecycle.
@objc public protocol NativeAdEventDelegate: AnyObject {
    
    /// Sent when the native ad is expired.
    @objc optional func adDidExpire(ad:NativeAd)
    
    /// Sent when the native view is clicked by the user.
    @objc optional func adWasClicked(ad:NativeAd)
    
    /// Sent when  an impression is recorded for an native ad
    @objc optional func adDidLogImpression(ad:NativeAd)
}
