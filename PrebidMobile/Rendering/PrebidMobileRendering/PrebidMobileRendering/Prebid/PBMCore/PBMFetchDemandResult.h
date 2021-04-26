//
//  PBMFetchDemandResult.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//
typedef NS_ENUM(NSUInteger, PBMFetchDemandResult) {
    PBMFetchDemandResult_Ok = 0,
    PBMFetchDemandResult_InvalidAccountId,
    PBMFetchDemandResult_InvalidConfigId,
    PBMFetchDemandResult_InvalidSize,
    PBMFetchDemandResult_NetworkError,
    PBMFetchDemandResult_ServerError,
    PBMFetchDemandResult_DemandNoBids,
    PBMFetchDemandResult_DemandTimedOut,
    
    PBMFetchDemandResult_InvalidResponseStructure = 1000,
    
    PBMFetchDemandResult_InternalSDKError = 7000,
    PBMFetchDemandResult_WrongArguments,
    PBMFetchDemandResult_NoVastTagInMediaData,

    PBMFetchDemandResult_SDKMisuse = 8000,
    PBMFetchDemandResult_SDKMisuse_NoNativeCreative,
    PBMFetchDemandResult_SDKMisuse_NativeAdUnitFetchedAgain,
    PBMFetchDemandResult_SDKMisuse_PreviousFetchNotCompletedYet,
    PBMFetchDemandResult_SDKMisuse_AttemptedToReplaceMediaDataInMediaView,
};

