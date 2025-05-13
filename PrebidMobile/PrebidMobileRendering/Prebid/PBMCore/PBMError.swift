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

@objc @_spi(PBMInternal) public
enum PBMErrorCode: Int {
    case generalLinear = 400
    case fileNotFound = 401
    case generalNonLinearAds = 500
    case general = 700
    case undefined = 900
}

enum PBMErrorFamily: Int {
    case setupErrors
    //case transportError
    case knownServerErrors
    case unknownServerErrors
    case responseProcessingErrors
    case integrationLayerErrors
    case incompatibleNativeAdMarkupAsset
    case SDKMisuseErrors
}

@objc @_spi(PBMInternal) public
class PBMErrorType: NSObject, RawRepresentable {
    public typealias RawValue = String
    @objc public let rawValue: String
    
    required public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    @objc public static let invalidRequest   = PBMErrorType(rawValue: "Invalid request")
    @objc public static let internalError    = PBMErrorType(rawValue: "SDK internal error")
    @objc public static let initError        = PBMErrorType(rawValue: "Initialization error")
    @objc public static let serverError      = PBMErrorType(rawValue: "Server error")
}

@objc @_spi(PBMInternal) public
class PBMError: NSError, @unchecked Sendable {
    static let errorDomain: String = "org.prebid.mobile"
    
    @objc public var message: String? {
        userInfo[NSLocalizedDescriptionKey] as? String
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(code: Int, userInfo: [String : Any]) {
        super.init(domain: Self.errorDomain,
                   code: code,
                   userInfo: userInfo)
    }
    
    convenience init(message: String, code: Int) {
        self.init(code: code,
                  userInfo: [
                    NSLocalizedDescriptionKey : message
                  ])
    }
    
    convenience init(message: String, code: PBMErrorCode) {
        self.init(message: message, code: code.rawValue)
    }
    
    convenience init(message: String) {
        self.init(code: PBMErrorCode.general.rawValue,
                  userInfo: [
                    NSLocalizedDescriptionKey : message
                  ])
    }
    
    @objc public static func error(message: String, type: PBMErrorType) -> PBMError {
        PBMError(message: "\(type.rawValue): \(message)", code: 0)
    }
    
    @objc public static func error(description: String) -> PBMError {
        error(description: description, statusCode: .general)
    }
    
    @objc public static func error(description: String, statusCode: PBMErrorCode) -> PBMError {
        PBMError(message: description, code: statusCode)
    }
    
    @objc @discardableResult
    public static func createError(_ error: UnsafeMutablePointer<NSError?>?,
                                   message: String,
                                   type: PBMErrorType) -> Bool {
        if let error {
            let err = PBMError.error(message: message, type: type)
            error.initialize(to: err)
            Log.error("\(err)")
            return true
        }
        return false
    }
    
    @objc @discardableResult
    public static func createError(_ error: UnsafeMutablePointer<NSError?>?,
                                   description: String) -> Bool {
        if let error {
            let err = PBMError.error(description: description)
            error.initialize(to: err)
            Log.error("\(err)")
            return true
        }
        return false
    }
    
    @objc @discardableResult
    public static func createError(_ error: UnsafeMutablePointer<NSError?>?,
                                   description: String,
                                   statusCode: PBMErrorCode) -> Bool {
        if let error {
            let err = PBMError.error(description: description, statusCode: statusCode)
            error.initialize(to: err)
            Log.error("\(err)")
            return true
        }
        return false
    }
    
    private static func errorCode(_ subCode: Int, forFamily family: PBMErrorFamily) -> Int {
        -(family.rawValue * 100 + subCode)
    }
    
    @objc public static func requestInProgress() -> NSError {
        NSError(domain: Self.errorDomain,
                code: Self.errorCode(1, forFamily: .setupErrors),
                userInfo: [
                    NSLocalizedDescriptionKey : "Network request already in progress",
                    NSLocalizedRecoverySuggestionErrorKey : "Wait for a competion handler to fire before attempting to send new requests",
                    PBM_FETCH_DEMAND_RESULT_KEY : ResultCode.prebidInternalSDKError.rawValue
                ])
    }
    
    // MARK: - Known server text errors
    
    @objc public static func prebidInvalidAccountId() -> NSError {
        NSError(domain: Self.errorDomain,
                code: Self.errorCode(1, forFamily: .knownServerErrors),
                userInfo: [
                    NSLocalizedDescriptionKey : "Prebid server does not recognize Account Id",
                    PBM_FETCH_DEMAND_RESULT_KEY : ResultCode.prebidInvalidAccountId.rawValue
                ])
    }
    
    @objc public static func prebidInvalidConfigId() -> NSError {
        NSError(domain: Self.errorDomain,
                code: Self.errorCode(2, forFamily: .knownServerErrors),
                userInfo: [
                    NSLocalizedDescriptionKey : "Prebid server does not recognize Config Id",
                    PBM_FETCH_DEMAND_RESULT_KEY : ResultCode.prebidInvalidConfigId.rawValue
                ])
    }
    
    @objc public static func prebidInvalidSize() -> NSError {
        NSError(domain: Self.errorDomain,
                code: Self.errorCode(3, forFamily: .knownServerErrors),
                userInfo: [
                    NSLocalizedDescriptionKey : "Prebid server does not recognize the size requested",
                    PBM_FETCH_DEMAND_RESULT_KEY : ResultCode.prebidInvalidSize.rawValue
                ])
    }
    
    @objc public static func prebidServerURLInvalid(_ url: String) -> NSError {
        NSError(domain: Self.errorDomain,
                code: Self.errorCode(4, forFamily: .knownServerErrors),
                userInfo: [
                    NSLocalizedDescriptionKey : "Prebid server URL \(url) is invalid",
                    PBM_FETCH_DEMAND_RESULT_KEY : ResultCode.prebidServerURLInvalid.rawValue
                ])
    }
    
    // MARK: - Unknown server text errors
    
    @objc public static func serverError(_ errorBody: String) -> NSError {
        NSError(domain: Self.errorDomain,
                code: Self.errorCode(1, forFamily: .unknownServerErrors),
                userInfo: [
                    NSLocalizedDescriptionKey : "Prebid Server Error",
                    NSLocalizedFailureReasonErrorKey : errorBody,
                    PBM_FETCH_DEMAND_RESULT_KEY : ResultCode.prebidServerError.rawValue
                ])
    }
    
    // MARK: - Response processing errors
    
    @objc public static func jsonDictNotFound() -> NSError {
        NSError(domain: Self.errorDomain,
                code: Self.errorCode(1, forFamily: .responseProcessingErrors),
                userInfo: [
                    NSLocalizedDescriptionKey : "The response does not contain a valid json dictionary",
                    PBM_FETCH_DEMAND_RESULT_KEY : ResultCode.prebidInvalidResponseStructure.rawValue
                ])
    }
    
    @objc public static func responseDeserializationFailed() -> NSError {
        NSError(domain: Self.errorDomain,
                code: Self.errorCode(2, forFamily: .responseProcessingErrors),
                userInfo: [
                    NSLocalizedDescriptionKey : "Failed to deserialize jsonDict from response into a proper BidResponse object",
                    PBM_FETCH_DEMAND_RESULT_KEY : ResultCode.prebidInvalidResponseStructure.rawValue
                ])
    }
    
    @objc public static func blankResponse() -> NSError {
        NSError(domain: Self.errorDomain,
                code: Self.errorCode(1, forFamily: .integrationLayerErrors),
                userInfo: [
                    NSLocalizedDescriptionKey : "The response is blank.",
                    PBM_FETCH_DEMAND_RESULT_KEY : ResultCode.prebidDemandNoBids.rawValue
                ])
    }
    
    // MARK: - Integration layer errors
    
    @objc public static func noWinningBid() -> NSError {
        NSError(domain: Self.errorDomain,
                code: Self.errorCode(1, forFamily: .integrationLayerErrors),
                userInfo: [
                    NSLocalizedDescriptionKey : "There is no winning bid in the bid response.",
                    PBM_FETCH_DEMAND_RESULT_KEY : ResultCode.prebidDemandNoBids.rawValue
                ])
    }
    
    @objc public static func prebidNoVastTagInMediaData() -> NSError {
        NSError(domain: Self.errorDomain,
                code: Self.errorCode(3, forFamily: .integrationLayerErrors),
                userInfo: [
                    NSLocalizedDescriptionKey : "Failed to find VAST Tag inside the provided Media Data.",
                    PBM_FETCH_DEMAND_RESULT_KEY : ResultCode.prebidNoVastTagInMediaData.rawValue
                ])
    }
    
    // MARK:  parsing
    // FIX ME
    class func demandResult(from error: Error?) -> ResultCode {
        guard let error = error as NSError? else {
            return .prebidDemandFetchSuccess
        }
        
        if error.domain == PBMError.errorDomain {
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
