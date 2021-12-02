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

#import "PBMError.h"
#import "PBMErrorFamily.h"
#import "PBMLog.h"

#import "PrebidMobileRenderingSwiftHeaders.h"

#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif


@implementation PBMError

// MARK: - Setup errors

+ (nonnull PBMError *)errorWithDescription:(nonnull NSString *)description {
    return [PBMError errorWithDescription:description statusCode:PBMErrorCodeGeneral];
}

+ (PBMError *)errorWithDescription:(NSString *)description statusCode:(PBMErrorCode)code {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(description, nil)
                               };
    
    return [PBMError errorWithDomain:PrebidRenderingErrorDomain
                                code:code
                            userInfo:userInfo];
}

+ (PBMError *)errorWithMessage:(NSString *)message type:(PBMErrorType)type {
    NSString *desc = [NSString stringWithFormat:@"%@: %@", type, message];
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:desc};
    return [PBMError errorWithDomain:PrebidRenderingErrorDomain code:0 userInfo:userInfo];
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
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:1
                                          forFamily:kPBMErrorFamily_SetupErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Network request already in progress",
        NSLocalizedRecoverySuggestionErrorKey: @"Wait for a competion handler to fire before attempting to send new requests",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultInternalSDKError),
    }];
}

// MARK: - Known server text errors

+ (NSError *)invalidAccountId {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:1
                                          forFamily:kPBMErrorFamily_KnownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Prebid server does not recognize Account Id",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultInvalidAccountId),
    }];
}

+ (NSError *)invalidConfigId {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:2
                                          forFamily:kPBMErrorFamily_KnownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Prebid server does not recognize Config Id",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultInvalidConfigId),
    }];
}

+ (NSError *)invalidSize {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:3
                                          forFamily:kPBMErrorFamily_KnownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Prebid server does not recognize the size requested",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultInvalidSize),
    }];
}

+ (NSError *)prebidServerURLInvalid:(NSString *)url {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:4
                                          forFamily:kPBMErrorFamily_KnownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Prebid server URL %@ is invalid", url],
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultInvalidHostUrl),
    }];
}

// MARK: - Unknown server text errors

+ (NSError *)serverError:(NSString *)errorBody {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:1
                                          forFamily:kPBMErrorFamily_UnknownServerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Prebid Server Error",
        NSLocalizedFailureReasonErrorKey: errorBody,
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultServerError),
    }];
}

// MARK: - Response processing errors

+ (NSError *)jsonDictNotFound {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:1
                                          forFamily:kPBMErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"The response does not contain a valid json dictionary",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultInvalidResponseStructure),
    }];
}

+ (NSError *)responseDeserializationFailed {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:2
                                          forFamily:kPBMErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Failed to deserialize jsonDict from response into a proper BidResponse object",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultInvalidResponseStructure),
    }];
}

+ (NSError *)noEventForNativeAdMarkupEventTracker {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:3
                                          forFamily:kPBMErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Required property 'event' is absent in jsonDict for nativeEventTracker",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultInvalidResponseStructure),
    }];
}

+ (NSError *)noMethodForNativeAdMarkupEventTracker {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:4
                                          forFamily:kPBMErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Required property 'method' is absent in jsonDict for nativeEventTracker",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultInvalidResponseStructure),
    }];
}

+ (NSError *)noUrlForNativeAdMarkupEventTracker {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:5
                                          forFamily:kPBMErrorFamily_ResponseProcessingErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Required property 'url' is absent in jsonDict for nativeEventTracker",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultInvalidResponseStructure),
    }];
}

// MARK: - Integration layer errors

+ (NSError *)noWinningBid {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:1
                                          forFamily:kPBMErrorFamily_IntegrationLayerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"There is no winning bid in the bid response.",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultDemandNoBids),
    }];
}

+ (NSError *)noNativeCreative {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:2
                                          forFamily:kPBMErrorFamily_IntegrationLayerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"There is no Native Style Creative in the Native config.",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultSdkMisuseNoNativeCreative),
    }];
}

+ (NSError *)noVastTagInMediaData {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:3
                                          forFamily:kPBMErrorFamily_IntegrationLayerErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Failed to find VAST Tag inside the provided Media Data.",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultNoVastTagInMediaData),
    }];
}

// MARK: - SDK Misuse Errors

+ (NSError *)replacingMediaDataInMediaView {
    return [NSError errorWithDomain:PrebidRenderingErrorDomain
                               code:[self errorCode:(FetchDemandResultSdkMisuseAttemptedToReplaceMediaDataInMediaView - FetchDemandResultSdkMisuse)
                                          forFamily:kPBMErrorFamily_SDKMisuseErrors]
                           userInfo:@{
        NSLocalizedDescriptionKey: @"Attempted to replace MediaData in MediaView.",
        PBM_FETCH_DEMAND_RESULT_KEY: @(FetchDemandResultSdkMisuseAttemptedToReplaceMediaDataInMediaView),
    }];
}


- (instancetype)init:(nonnull NSString*)msg {
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(msg, nil)
                               };
    
    self = [super initWithDomain:PrebidRenderingErrorDomain code:PBMErrorCodeGeneral userInfo:userInfo];
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
