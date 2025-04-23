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

/**
 Provides info about received ad.
 */
@objc(PBMAdDetails)
public class AdDetails: NSObject {
    
    /**
     Raw data returned for the ad request.
     */
    @objc public let rawResponse: String
    
    /**
     Unique identifier of the ad, that can be used for managing and reporting ad quality issues.
     */
    @objc public let transactionId: String
    
    init(rawResponse: String,
         transactionId: String) {
        self.rawResponse = rawResponse
        self.transactionId = transactionId
    }
    
}
