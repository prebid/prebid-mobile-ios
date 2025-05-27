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

@objc
public protocol PrebidEventDelegate {
    /// Notifies the delegate when a Prebid bid request has finished.
    ///
    /// This method is called on a global background thread.
    ///
    /// - Parameters:
    ///   - requestData: The Prebid Server request data that was sent.
    ///   - responseData: The Prebid Server response data that was received.
    func prebidBidRequestDidFinish(requestData: Data?, responseData: Data?)
}
