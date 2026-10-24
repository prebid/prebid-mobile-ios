//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

// The VAST error codes the SDK reports through the `[ERRORCODE]` macro of an `<Error>` URI
// (VAST 4.3, section 2.3.6.3).
enum VastErrorCode: Int {

    // No VAST response after one or more Wrappers. Reported for a no-ad response (section 2.3.6.4).
    case noAdAfterWrappers = 303

    // The InLine response did not produce an ad within the time limit (section 2.3.5.1).
    case adNotProducedInTime = 304

    // File not found: the MediaFile could not be fetched from its URI.
    case mediaFileNotFound = 401

    // The MediaFile was fetched, but the player could not display it.
    case mediaFileDisplayProblem = 405

    // The ad server expects the player to fill in the macro. Left in place, its brackets also keep the
    // URI from becoming a URL on iOS 17 and later, so the request is never sent. The percent-encoded
    // form is replaced too, for servers that encode the whole URI.
    func replacingMacro(in uri: String) -> String {
        let errorCode = String(rawValue)
        return uri.replacingOccurrences(of: "[ERRORCODE]", with: errorCode)
            .replacingOccurrences(of: "%5BERRORCODE%5D", with: errorCode, options: .caseInsensitive)
    }
}
