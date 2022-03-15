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

import XCTest

@testable import PrebidMobile

class PBMErrorTest: XCTestCase {
    func testErrorCollisions() {
        let allErrors = [
            PBMError.requestInProgress,
            
            PBMError.invalidAccountId,
            PBMError.invalidConfigId,
            PBMError.invalidSize,
            
            PBMError.serverError("some error reason"),
            
            PBMError.jsonDictNotFound,
            PBMError.responseDeserializationFailed,
            
            PBMError.noWinningBid,
        ].map { $0 as NSError }
        
        for i in 1..<allErrors.count {
            for j in 0..<i {
                XCTAssertNotEqual(allErrors[i].code, allErrors[j].code,
                                  "\(i)('\(allErrors[i])' vs #\(j)('\(allErrors[j])'")
                XCTAssertNotEqual(allErrors[i].localizedDescription, allErrors[j].localizedDescription,
                                  "\(i)('\(allErrors[i])' vs #\(j)('\(allErrors[j])'")
            }
        }
    }
    
    func testErrorParsing() {
        let errors: [(Error?, ResultCode)] = [
            (PBMError.requestInProgress, .internalSDKError),
            
            (PBMError.invalidAccountId, .invalidAccountId),
            (PBMError.invalidConfigId, .invalidConfigId),
            (PBMError.invalidSize, .invalidSize),
            
            (PBMError.serverError("some error reason"), .serverError),
            
            (PBMError.jsonDictNotFound, .invalidResponseStructure),
            (PBMError.responseDeserializationFailed, .invalidResponseStructure),
            
            (PBMError.noWinningBid, .demandNoBids),
            
            
            (NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut), .demandTimedOut),
            (NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL), .networkError),
            
            (nil, .ok),
        ]
        
        for (error, code) in errors {
            XCTAssertEqual(PBMError.demandResult(from: error), code)
        }
    }
    
    func testInitWithMessage() {
        let error = PBMError(message: "MyError")
        XCTAssert(error.message == "MyError")
    }
    
    func testInitWithDescription() {
        let error = PBMError.error(description: "MyErrorDescription")
        
        // Verify default values
        XCTAssert(error.domain == PrebidRenderingErrorDomain)
        XCTAssert(error.code == 700)
        XCTAssert(error.userInfo["NSLocalizedDescription"] as! String == "MyErrorDescription")
    }
    
    func testInitWithMessageAndType() {
        let errorMessage = "ERROR MESSAGE"
        let err = PBMError.error(message: errorMessage, type: .internalError)
        XCTAssert(err.localizedDescription.PBMdoesMatch(errorMessage), "error should have \(errorMessage) in its description")
    }
    
    func testCreateErrorWithDescriptionNegative() {
        var error = PBMError.createError(nil, description: "")
        XCTAssertFalse(error)
        
        error = PBMError.createError(nil, message: "", type: .invalidRequest)
        XCTAssertFalse(error)
        
        error = PBMError.createError(nil, description: "", statusCode: .generalLinear)
        XCTAssertFalse(error)
    }
}
