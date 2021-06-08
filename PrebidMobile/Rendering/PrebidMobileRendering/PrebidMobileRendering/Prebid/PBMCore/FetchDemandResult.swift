//
//  FetchDemandResult.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

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
    case sdkMisuseNoNativeCreative
    case sdkMisuseNativeAdUnitFetchedAgain
    case sdkMisusePreviousFetchNotCompletedYet
    case sdkMisuseAttemptedToReplaceMediaDataInMediaView
}
