/*   Copyright 2018-2021 Prebid.org, Inc.

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

/// Reads the IAB consent signals the host app writes into `UserDefaults`.
///
/// No ObjC consumer remains, so the type carries no `@objc` exposure: it would otherwise be
/// emitted into the generated `-Swift.h` for nothing.
final class InternalUserConsentDataManager {

    static var IABUSPrivacy_StringKey: String {
        "IABUSPrivacy_String"
    }

    static var IABGPP_HDR_GppString: String {
        "IABGPP_HDR_GppString"
    }

    static var IABGPP_GppSID: String {
        "IABGPP_GppSID"
    }

    static var usPrivacyString: String? {
        UserDefaults.standard.string(forKey: InternalUserConsentDataManager.IABUSPrivacy_StringKey)
    }

    static var gppHDRString: String? {
        UserDefaults.standard.string(forKey: InternalUserConsentDataManager.IABGPP_HDR_GppString)
    }

    static var gppSID: [NSNumber] {
        guard let gppSID = UserDefaults.standard.string(forKey: InternalUserConsentDataManager.IABGPP_GppSID),
              !gppSID.isEmpty else {
            return []
        }

        // `strictNumberValue` rather than `NumberFormatter`: the section IDs are a spec-defined run
        // of digits and must resolve identically regardless of `Locale.current`'s separators.
        return gppSID.components(separatedBy: "_").compactMap { $0.strictNumberValue }
    }
}
