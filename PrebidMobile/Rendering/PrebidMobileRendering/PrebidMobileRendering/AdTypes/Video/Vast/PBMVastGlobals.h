//
//  PBMVastGlobals.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PBMVastResourceType) {
    PBMVastResourceTypeStaticResource,
    PBMVastResourceTypeIFrameResource,
    PBMVastResourceTypeHtmlResource,
};

typedef NSString * const _Nonnull PBMVastRequiredMode NS_TYPED_ENUM;
FOUNDATION_EXPORT PBMVastRequiredMode const PBMVastRequiredModeAll;
FOUNDATION_EXPORT PBMVastRequiredMode const PBMVastRequiredModeAny;
FOUNDATION_EXPORT PBMVastRequiredMode const PBMVastRequiredModeNone;

typedef NS_ENUM(NSInteger, PBMVASTError) {
    PBMVASTErrorParsing = 100,
    PBMVASTErrorValidation,
    PBMVASTErrorUnsupportedVersion,
    PBMVASTErrorUnexpectedAdType = 200,
    PBMVASTErrorUnexpectedCreativeType,
    PBMVASTErrorUnexpectedDuration,
    PBMVASTErrorUnexpectedSize,
    PBMVASTErrorGenericWrapperError = 300,
    PBMVASTErrorWrapperTimeout,
    PBMVASTErrorWrapperLimitReached,
    PBMVASTErrorNoAdsResponse,
    PBMVASTErrorGenericLinearError = 400,
    PBMVASTErrorLinearMediaNotFound,
    PBMVASTErrorMediaFileTimeout,
    PBMVASTErrorLinearMediaUnsupported,
    PBMVASTErrorMediaFilePlayback,
    PBMVASTErrorGenericNonLinearError = 500,
    PBMVASTErrorNonLinearDimensions,
    PBMVASTErrorNonLinearMediaNotFound,
    PBMVASTErrorNonLinearResourceUnsupported,
    PBMVASTErrorGenericCompanionError = 600,
    PBMVASTErrorCompanionDimensions,
    PBMVASTErrorRequiredCompanionUnavailable,
    PBMVASTErrorCompanionMediaNotFound,
    PBMVASTErrorCompanionResourceUnsupported,
    PBMVASTErrorUndefinedError = 900
};
