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

enum MAXAdaptersError {
    case noTargetingInfoInBid
    case noServerParameter
    case wrongServerParameter
    case noBidInLocalExtraParameters
    case noConfigIdInLocalExtraParameters
}

extension MAXAdaptersError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .noTargetingInfoInBid:
            return "There is no targeting info in bid"
        case .noServerParameter:
            return "There is no server parameter in local extra parameters"
        case .wrongServerParameter:
            return "Targeting info doesn't contain server parameter"
        case .noBidInLocalExtraParameters:
            return "Bid object is absent in the local extra parameters"
        case .noConfigIdInLocalExtraParameters:
            return "Config id is absent in the local extra parameters"
        }
    }
}
