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

@objc public enum FetchDemandResult : Int {
    case ok = 0
    case invalidAccountId
    case invalidConfigId
    case invalidSize
    case networkError
    case serverError
    case demandNoBids
    case demandTimedOut
    case invalidHostUrl
    
    case invalidResponseStructure = 1000
    
    case internalSDKError = 7000
    case wrongArguments
    case noVastTagInMediaData

    case sdkMisuse = 8000
    case sdkMisusePreviousFetchNotCompletedYet
}
