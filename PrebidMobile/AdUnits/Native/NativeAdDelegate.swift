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

@objc public protocol NativeAdDelegate : AnyObject {
    
    ///  A successful Prebid Native ad is returned
    /// - Parameter:  A successful Prebid Native ad is returned
    func nativeAdLoaded(ad: NativeAd)
    
    /// Prebid Native was not found in the server returned response,
    /// Please display the ad as regular ways
    func nativeAdNotFound()
    
    /// Prebid Native ad was returned, however, the bid is not valid for displaying
    /// Should be treated as on ad load failed
    func nativeAdNotValid()
}
