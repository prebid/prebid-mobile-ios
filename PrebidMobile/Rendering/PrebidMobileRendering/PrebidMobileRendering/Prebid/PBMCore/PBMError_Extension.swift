//
//  PBMError_Extension.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public extension PBMError {
    
    // MARK: -  parsing
    // FIX ME
    class func demandResult(from error: Error?) -> FetchDemandResult {
        guard let error = error as NSError? else {
            return .ok
        }
        
        if error.domain == PrebidRenderingErrorDomain {
            if let demandCode = error.userInfo[PBM_FETCH_DEMAND_RESULT_KEY] as? NSNumber,
               let res = FetchDemandResult(rawValue: demandCode.intValue)  {
                return res
            } else {
                return .internalSDKError
            }
        }
        
        if error.domain == NSURLErrorDomain,
           error.code == NSURLErrorTimedOut {
            return .demandTimedOut
        }
        
        return .networkError
    }
    
}
