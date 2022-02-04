/*   Copyright 2018-2019 Prebid.org, Inc.

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

@objc public enum ResultCode: Int {
    case prebidDemandFetchSuccess
    case prebidServerNotSpecified
    case prebidInvalidAccountId
    case prebidInvalidConfigId
    case prebidInvalidSize
    case prebidNetworkError
    case prebidServerURLInvalid
    case prebidServerError
    case prebidDemandNoBids
    case prebidDemandTimedOut
    case prebidUnknownError

    public func name () -> String {
        switch self {
        case .prebidDemandFetchSuccess: return "Prebid Demand Fetch Successful"
        case .prebidServerNotSpecified: return "Prebid Server not specified"
        case .prebidInvalidAccountId: return "Prebid server does not recognize Account Id"
        case .prebidInvalidConfigId: return "Prebid server does not recognize Config Id"
        case .prebidInvalidSize: return "Prebid server does not recognize the size requested"
        case .prebidNetworkError: return "Network Error"
        case .prebidServerURLInvalid: return "Prebid Server url invalid"
        case .prebidServerError: return "Prebid Server Error"
        case .prebidDemandNoBids: return "Prebid Server did not return bids"
        case .prebidDemandTimedOut: return "Prebid demand timedout"
        case .prebidUnknownError: return "Prebid unknown error occurred"
        }
    }
}
