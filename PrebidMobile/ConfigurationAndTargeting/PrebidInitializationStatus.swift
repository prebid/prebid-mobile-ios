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

/// Enum representing the initialization status of the Prebid SDK.
///
/// This enum provides various statuses that indicate the result of the Prebid SDK initialization process. It helps in understanding whether the SDK was successfully initialized or if there were issues during the initialization.
@objc public enum PrebidInitializationStatus: Int {
    /// Prebid SDK successfully initialized.
    case succeeded
    /// Prebid SDK is not able to work.
    case failed
    /// Something went wrong during PBS status checking.
    case serverStatusWarning
}
