//
//  PBMError.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMError.h"
#import "PBMPublicConstants.h"
#import "PBMErrorFamily.h"
#import "PBMLog.h"

static NSString * const oxbFetchDemandResultKey = @"oxbFetchDemandResultKey";

@implementation PBMError

// MARK: - Setup errors

+ (nonnull PBMError *)errorWithDescription:(nonnull NSString *)description {
    return [PBMError errorWithDescription:description statusCode:PBMErrorCodeGeneral];
}

+ (PBMError *)errorWithDescription:(NSString *)description statusCode:(PBMErrorCode)code {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil)
                               };
    
    return [PBMError errorWithDomain:PBMErrorDomain
                                code:code
                            userInfo:userInfo];
}

+ (PBMError *)errorWithMessage:(NSString *)message type:(PBMErrorType)type {
    NSString *desc = [NSString stringWithFormat:@"%@: %@", type, message];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:desc};
    return [PBMError errorWithDomain:PBMErrorDomain code:0 userInfo:userInfo];
}

+ (BOOL)createError:(NSError *__autoreleasing  _Nullable *)error description:(NSString *)description {
    if (error != NULL) {
        *error = [PBMError errorWithDescription:description];
        PBMLogError(@"%@", *error);
        return YES;
    }
    return NO;
}

+ (BOOL)createError:(NSError *__autoreleasing  _Nullable *)error description:(NSString *)description statusCode:(PBMErrorCode)code {
    if (error != NULL) {
        *error = [PBMError errorWithDescription:description statusCode:code];
        PBMLogError(@"%@", *error);
        return YES;
    }
    return NO;
}

+ (BOOL)createError:(NSError *__autoreleasing  _Nullable *)error message:(NSString *)message type:(PBMErrorType)type {
    if (error != NULL) {
        *error = [PBMError errorWithMessage:message type:type];
        PBMLogError(@"%@", *error);
        return YES;
    }
    return NO;
}


+ (NSError *)requestInProgress {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:1
                                          forFamily:kPBMErrorFamily_SetupErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Network request already in progress",
        NSLocalizedRecoverySuggestionErrorKey: @"Wait for a competion handler to fire before attempting to send new requests",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_InternalSDKError),
    }];
}

// MARK: - Known server text errors

+ (NSError *)invalidAccountId {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:1
                                          forFamily:kPBMErrorFamily_KnownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Prebid server does not recognize Account Id",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_InvalidAccountId),
    }];
}

+ (NSError *)invalidConfigId {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:2
                                          forFamily:kPBMErrorFamily_KnownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Prebid server does not recognize Config Id",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_InvalidConfigId),
    }];
}

+ (NSError *)invalidSize {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:3
                                          forFamily:kPBMErrorFamily_KnownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Prebid server does not recognize the size requested",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_InvalidSize),
    }];
}

// MARK: - Unknown server text errors

+ (NSError *)serverError:(NSString *)errorBody {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:1
                                          forFamily:kPBMErrorFamily_UnknownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Prebid Server Error",
        NSLocalizedFailureReasonErrorKey: errorBody,
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_ServerError),
    }];
}

// MARK: - Response processing errors

+ (NSError *)jsonDictNotFound {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:1
                                          forFamily:kPBMErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"The response does not contain a valid json dictionary",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_InvalidResponseStructure),
    }];
}

+ (NSError *)responseDeserializationFailed {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:2
                                          forFamily:kPBMErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Failed to deserialize jsonDict from response into a proper BidResponse object",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_InvalidResponseStructure),
    }];
}

+ (NSError *)noEventForNativeAdMarkupEventTracker {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:3
                                          forFamily:kPBMErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Required property 'event' is absent in jsonDict for nativeEventTracker",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_InvalidResponseStructure),
    }];
}

+ (NSError *)noMethodForNativeAdMarkupEventTracker {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:4
                                          forFamily:kPBMErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Required property 'method' is absent in jsonDict for nativeEventTracker",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_InvalidResponseStructure),
    }];
}

+ (NSError *)noUrlForNativeAdMarkupEventTracker {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:5
                                          forFamily:kPBMErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Required property 'url' is absent in jsonDict for nativeEventTracker",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_InvalidResponseStructure),
    }];
}

// MARK: - Integration layer errors

+ (NSError *)noWinningBid {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:1
                                          forFamily:kPBMErrorFamily_IntegrationLayerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"There is no winning bid in the bid response.",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_DemandNoBids),
    }];
}

+ (NSError *)noNativeCreative {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:2
                                          forFamily:kPBMErrorFamily_IntegrationLayerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"There is no Native Style Creative in the Native config.",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_SDKMisuse_NoNativeCreative),
    }];
}

+ (NSError *)noVastTagInMediaData {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:3
                                          forFamily:kPBMErrorFamily_IntegrationLayerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Failed to find VAST Tag inside the provided Media Data.",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_NoVastTagInMediaData),
    }];
}

// MARK: - SDK Misuse Errors

+ (NSError *)replacingMediaDataInMediaView {
    return [NSError errorWithDomain:pbmErrorDomain
                               code:[self errorCode:(PBMFetchDemandResult_SDKMisuse_AttemptedToReplaceMediaDataInMediaView - PBMFetchDemandResult_SDKMisuse)
                                          forFamily:kPBMErrorFamily_SDKMisuseErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Attempted to replace MediaData in MediaView.",
        oxbFetchDemandResultKey: @(PBMFetchDemandResult_SDKMisuse_AttemptedToReplaceMediaDataInMediaView),
    }];
}

// MARK: - PBMFetchDemandResult parsing

+ (PBMFetchDemandResult)demandResultFromError:(NSError *)error {
    if (!error) {
        return PBMFetchDemandResult_Ok;
    }
    if ([error.domain isEqualToString:pbmErrorDomain]) {
        NSNumber * const demandCode = error.userInfo[oxbFetchDemandResultKey];
        return demandCode ? (PBMFetchDemandResult)demandCode.integerValue : PBMFetchDemandResult_InternalSDKError;
    }
    if ([error.domain isEqualToString:NSURLErrorDomain] && (error.code == NSURLErrorTimedOut)) {
        return PBMFetchDemandResult_DemandTimedOut;
    }
    return PBMFetchDemandResult_NetworkError;
}

- (instancetype)init:(nonnull NSString*)msg {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(msg, nil)
                               };
    
    self = [super initWithDomain:PBMErrorDomain code:PBMErrorCodeGeneral userInfo:userInfo];
    if (self) {
        self.message = msg;
    }

    return self;
}

// MARK: - Private Helpers

+ (NSInteger)errorCode:(NSInteger)subCode forFamily:(PBMErrorFamily)errorFamily {
    return pbmErrorCode(errorFamily, subCode);
}

@end
