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

@objc(PBMResultCode)
public enum ResultCode: Int {
    case prebidDemandFetchSuccess = 0
    case prebidServerNotSpecified
    case prebidInvalidAccountId
    case prebidInvalidConfigId
    case prebidInvalidSize
    case prebidNetworkError
    case prebidServerError
    case prebidDemandNoBids
    case prebidDemandTimedOut
    case prebidServerURLInvalid
    case prebidUnknownError
    
    case prebidInvalidResponseStructure = 1000
    
    case prebidInternalSDKError = 7000
    case prebidWrongArguments
    case prebidNoVastTagInMediaData

    case prebidSDKMisuse = 8000
    case prebidSDKMisusePreviousFetchNotCompletedYet
    
    public func name () -> String {
        switch self {
        
        case .prebidDemandFetchSuccess:
            return "Prebid demand fetch successful"
        case .prebidServerNotSpecified:
            return "Prebid server not specified"
        case .prebidInvalidAccountId:
            return "Prebid server does not recognize account id"
        case .prebidInvalidConfigId:
            return "Prebid server does not recognize config id"
        case .prebidInvalidSize:
            return "Prebid server does not recognize the size requested"
        case .prebidNetworkError:
            return "Network Error"
        case .prebidServerError:
            return "Prebid server error"
        case .prebidDemandNoBids:
            return "Prebid Server did not return bids"
        case .prebidDemandTimedOut:
            return "Prebid demand timedout"
        case .prebidServerURLInvalid:
            return "Prebid server url is invalid"
        case .prebidUnknownError:
            return "Prebid unknown error occurred"
        case .prebidInvalidResponseStructure:
            return "Response structure is invalid"
        case .prebidInternalSDKError:
            return "Internal SDK error"
        case .prebidWrongArguments:
            return "Wrong arguments"
        case .prebidNoVastTagInMediaData:
            return "No VAST tag in media data"
        case .prebidSDKMisuse:
            return "SDK misuse"
        case .prebidSDKMisusePreviousFetchNotCompletedYet:
            return "SDK misuse, previous fetch has not complete yet"
        }
    }
}
