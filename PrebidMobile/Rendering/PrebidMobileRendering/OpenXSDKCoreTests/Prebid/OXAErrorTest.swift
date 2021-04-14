//
//  OXAErrorTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXAErrorTest: XCTestCase {
    func testErrorCollisions() {
        let allErrors = [
            OXAError.requestInProgress,
            
            OXAError.invalidAccountId,
            OXAError.invalidConfigId,
            OXAError.invalidSize,
            
            OXAError.serverError("some error reason"),
            
            OXAError.jsonDictNotFound,
            OXAError.responseDeserializationFailed,
            
            OXAError.noEventForNativeAdMarkupEventTracker,
            OXAError.noMethodForNativeAdMarkupEventTracker,
            OXAError.noUrlForNativeAdMarkupEventTracker,
            
            OXAError.noWinningBid,
            OXAError.noNativeCreative,
            
            OXANativeAdAssetBoxingError.noDataInsideNativeAdMarkupAsset,
            OXANativeAdAssetBoxingError.noImageInsideNativeAdMarkupAsset,
            OXANativeAdAssetBoxingError.noTitleInsideNativeAdMarkupAsset,
            OXANativeAdAssetBoxingError.noVideoInsideNativeAdMarkupAsset,
            
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
        let errors: [(Error?, OXAFetchDemandResult)] = [
            (OXAError.requestInProgress, .internalSDKError),
        
            (OXAError.invalidAccountId, .invalidAccountId),
            (OXAError.invalidConfigId, .invalidConfigId),
            (OXAError.invalidSize, .invalidSize),
        
            (OXAError.serverError("some error reason"), .serverError),
        
            (OXAError.jsonDictNotFound, .invalidResponseStructure),
            (OXAError.responseDeserializationFailed, .invalidResponseStructure),
            
            (OXAError.noWinningBid, .demandNoBids),
            
            (OXAError.noNativeCreative, .sdkMisuse_NoNativeCreative),
            
            (NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut), .demandTimedOut),
            (NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL), .networkError),
            
            (nil, .ok),
        ]
        
        for (error, code) in errors {
            XCTAssertEqual(OXAError.demandResult(fromError: error), code)
        }
    }
}
