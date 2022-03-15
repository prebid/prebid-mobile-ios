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

@objc public extension PBMError {
    
    // MARK: -  parsing
    // FIX ME
    class func demandResult(from error: Error?) -> ResultCode {
        guard let error = error as NSError? else {
            return .prebidDemandFetchSuccess
        }
        
        if error.domain == PrebidRenderingErrorDomain {
            if let demandCode = error.userInfo[PBM_FETCH_DEMAND_RESULT_KEY] as? NSNumber,
               let res = ResultCode(rawValue: demandCode.intValue)  {
                return res
            } else {
                return .prebidInternalSDKError
            }
        }
        
        if error.domain == NSURLErrorDomain,
           error.code == NSURLErrorTimedOut {
            return .prebidDemandTimedOut
        }
        
        return .prebidNetworkError
    }
    
}
