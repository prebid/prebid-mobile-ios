/*   Copyright 2018-2026 Prebid.org, Inc.

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

/// Where the SDK places Extended Identifiers (EIDs) in the bid request.
///
/// OpenRTB 2.6 moved EIDs from `user.ext.eids` to `user.eids`. Prebid Server reads `user.eids`
/// and ignores `user.ext.eids` whenever `user.eids` is present.
@objc public enum EidsPlacement: Int {
    /// EIDs are sent only in `user.eids` (OpenRTB 2.6).
    case openRTB26
    /// EIDs are sent only in `user.ext.eids` (OpenRTB 2.5).
    case openRTB25
    /// The same EIDs are sent in both `user.eids` and `user.ext.eids`.
    case compatible
}
