//
//  OXAError.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAError.h"
#import "OXAErrorFamily.h"

static NSString * const oxbFetchDemandResultKey = @"oxbFetchDemandResultKey";

@implementation OXAError

// MARK: - Setup errors

+ (NSError *)requestInProgress {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:1
                                          forFamily:kOXAErrorFamily_SetupErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Network request already in progress",
        NSLocalizedRecoverySuggestionErrorKey: @"Wait for a competion handler to fire before attempting to send new requests",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_InternalSDKError),
    }];
}

// MARK: - Known server text errors

+ (NSError *)invalidAccountId {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:1
                                          forFamily:kOXAErrorFamily_KnownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Prebid server does not recognize Account Id",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_InvalidAccountId),
    }];
}

+ (NSError *)invalidConfigId {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:2
                                          forFamily:kOXAErrorFamily_KnownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Prebid server does not recognize Config Id",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_InvalidConfigId),
    }];
}

+ (NSError *)invalidSize {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:3
                                          forFamily:kOXAErrorFamily_KnownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Prebid server does not recognize the size requested",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_InvalidSize),
    }];
}

// MARK: - Unknown server text errors

+ (NSError *)serverError:(NSString *)errorBody {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:1
                                          forFamily:kOXAErrorFamily_UnknownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Prebid Server Error",
        NSLocalizedFailureReasonErrorKey: errorBody,
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_ServerError),
    }];
}

// MARK: - Response processing errors

+ (NSError *)jsonDictNotFound {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:1
                                          forFamily:kOXAErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"The response does not contain a valid json dictionary",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_InvalidResponseStructure),
    }];
}

+ (NSError *)responseDeserializationFailed {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:2
                                          forFamily:kOXAErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Failed to deserialize jsonDict from response into a proper BidResponse object",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_InvalidResponseStructure),
    }];
}

+ (NSError *)noEventForNativeAdMarkupEventTracker {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:3
                                          forFamily:kOXAErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Required property 'event' is absent in jsonDict for nativeEventTracker",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_InvalidResponseStructure),
    }];
}

+ (NSError *)noMethodForNativeAdMarkupEventTracker {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:4
                                          forFamily:kOXAErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Required property 'method' is absent in jsonDict for nativeEventTracker",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_InvalidResponseStructure),
    }];
}

+ (NSError *)noUrlForNativeAdMarkupEventTracker {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:5
                                          forFamily:kOXAErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Required property 'url' is absent in jsonDict for nativeEventTracker",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_InvalidResponseStructure),
    }];
}

// MARK: - Integration layer errors

+ (NSError *)noWinningBid {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:1
                                          forFamily:kOXAErrorFamily_IntegrationLayerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"There is no winning bid in the bid response.",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_DemandNoBids),
    }];
}

+ (NSError *)noNativeCreative {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:2
                                          forFamily:kOXAErrorFamily_IntegrationLayerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"There is no Native Style Creative in the Native config.",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_SDKMisuse_NoNativeCreative),
    }];
}

+ (NSError *)noVastTagInMediaData {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:3
                                          forFamily:kOXAErrorFamily_IntegrationLayerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Failed to find VAST Tag inside the provided Media Data.",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_NoVastTagInMediaData),
    }];
}

// MARK: - SDK Misuse Errors

+ (NSError *)replacingMediaDataInMediaView {
    return [NSError errorWithDomain:oxaErrorDomain
                               code:[self errorCode:(OXAFetchDemandResult_SDKMisuse_AttemptedToReplaceMediaDataInMediaView - OXAFetchDemandResult_SDKMisuse)
                                          forFamily:kOXAErrorFamily_SDKMisuseErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Attempted to replace MediaData in MediaView.",
        oxbFetchDemandResultKey: @(OXAFetchDemandResult_SDKMisuse_AttemptedToReplaceMediaDataInMediaView),
    }];
}

// MARK: - OXAFetchDemandResult parsing

+ (OXAFetchDemandResult)demandResultFromError:(NSError *)error {
    if (!error) {
        return OXAFetchDemandResult_Ok;
    }
    if ([error.domain isEqualToString:oxaErrorDomain]) {
        NSNumber * const demandCode = error.userInfo[oxbFetchDemandResultKey];
        return demandCode ? (OXAFetchDemandResult)demandCode.integerValue : OXAFetchDemandResult_InternalSDKError;
    }
    if ([error.domain isEqualToString:NSURLErrorDomain] && (error.code == NSURLErrorTimedOut)) {
        return OXAFetchDemandResult_DemandTimedOut;
    }
    return OXAFetchDemandResult_NetworkError;
}

// MARK: - Private Helpers

+ (NSInteger)errorCode:(NSInteger)subCode forFamily:(OXAErrorFamily)errorFamily {
    return oxaErrorCode(errorFamily, subCode);
}

@end
