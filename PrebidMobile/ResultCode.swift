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

/// Enum representing the result codes for various operations within the Prebid SDK.
///
/// This enum provides a range of result codes indicating different outcomes or errors that may occur during SDK operations. Each case corresponds to a specific result or error, which helps in diagnosing issues and understanding the status of SDK operations.
@objc public enum ResultCode : Int {
    
    /// The demand fetch request was successful.
    case prebidDemandFetchSuccess = 0
    
    /// The Prebid server was not specified in the request.
    case prebidServerNotSpecified
    
    /// The account ID provided is not recognized by the Prebid server.
    case prebidInvalidAccountId
    
    /// The config ID provided is not recognized by the Prebid server.
    case prebidInvalidConfigId
    
    /// The size requested is not recognized by the Prebid server.
    case prebidInvalidSize
    
    /// There was a network error during the operation.
    case prebidNetworkError
    
    /// The Prebid server encountered an error while processing the request.
    case prebidServerError
    
    /// The Prebid server did not return any bids.
    case prebidDemandNoBids
    
    /// The demand request timed out.
    case prebidDemandTimedOut
    
    /// The URL of the Prebid server is invalid.
    case prebidServerURLInvalid
    
    /// An unknown error occurred within the Prebid SDK.
    case prebidUnknownError
    
    /// The structure of the response received is invalid.
    case prebidInvalidResponseStructure = 1000
    
    /// An internal error occurred within the SDK.
    case prebidInternalSDKError = 7000
    
    /// Incorrect arguments were provided to the SDK.
    case prebidWrongArguments
    
    /// No VAST tag was found in the media data.
    case prebidNoVastTagInMediaData

    /// Misuse of the SDK was detected.
    case prebidSDKMisuse = 8000
    
    /// SDK misuse due to a previous fetch operation not being completed yet.
    case prebidSDKMisusePreviousFetchNotCompletedYet
    
    /// The Prebid request does not contain any parameters.
    case prebidInvalidRequest
    
    /// Returns a descriptive name for the result code.
    public func name() -> String {
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
        case .prebidInvalidRequest:
            return "Prebid Request does not contain any parameters"
        }
    }
}
