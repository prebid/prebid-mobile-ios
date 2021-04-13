//
//  OXAFetchDemandResult.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//
typedef NS_ENUM(NSUInteger, OXAFetchDemandResult) {
    OXAFetchDemandResult_Ok = 0,
    OXAFetchDemandResult_InvalidAccountId,
    OXAFetchDemandResult_InvalidConfigId,
    OXAFetchDemandResult_InvalidSize,
    OXAFetchDemandResult_NetworkError,
    OXAFetchDemandResult_ServerError,
    OXAFetchDemandResult_DemandNoBids,
    OXAFetchDemandResult_DemandTimedOut,
    
    OXAFetchDemandResult_InvalidResponseStructure = 1000,
    
    OXAFetchDemandResult_InternalSDKError = 7000,
    OXAFetchDemandResult_WrongArguments,
    OXAFetchDemandResult_NoVastTagInMediaData,

    OXAFetchDemandResult_SDKMisuse = 8000,
    OXAFetchDemandResult_SDKMisuse_NoNativeCreative,
    OXAFetchDemandResult_SDKMisuse_NativeAdUnitFetchedAgain,
    OXAFetchDemandResult_SDKMisuse_PreviousFetchNotCompletedYet,
    OXAFetchDemandResult_SDKMisuse_AttemptedToReplaceMediaDataInMediaView,
};

