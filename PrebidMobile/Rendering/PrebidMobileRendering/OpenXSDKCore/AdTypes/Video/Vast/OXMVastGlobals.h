//
//  OXMVastGlobals.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, OXMVastResourceType) {
    OXMVastResourceTypeStaticResource,
    OXMVastResourceTypeIFrameResource,
    OXMVastResourceTypeHtmlResource,
};

typedef NSString * const _Nonnull OXMVastRequiredMode NS_TYPED_ENUM;
FOUNDATION_EXPORT OXMVastRequiredMode const OXMVastRequiredModeAll;
FOUNDATION_EXPORT OXMVastRequiredMode const OXMVastRequiredModeAny;
FOUNDATION_EXPORT OXMVastRequiredMode const OXMVastRequiredModeNone;

typedef NS_ENUM(NSInteger, OXMVASTError) {
    OXMVASTErrorParsing = 100,
    OXMVASTErrorValidation,
    OXMVASTErrorUnsupportedVersion,
    OXMVASTErrorUnexpectedAdType = 200,
    OXMVASTErrorUnexpectedCreativeType,
    OXMVASTErrorUnexpectedDuration,
    OXMVASTErrorUnexpectedSize,
    OXMVASTErrorGenericWrapperError = 300,
    OXMVASTErrorWrapperTimeout,
    OXMVASTErrorWrapperLimitReached,
    OXMVASTErrorNoAdsResponse,
    OXMVASTErrorGenericLinearError = 400,
    OXMVASTErrorLinearMediaNotFound,
    OXMVASTErrorMediaFileTimeout,
    OXMVASTErrorLinearMediaUnsupported,
    OXMVASTErrorMediaFilePlayback,
    OXMVASTErrorGenericNonLinearError = 500,
    OXMVASTErrorNonLinearDimensions,
    OXMVASTErrorNonLinearMediaNotFound,
    OXMVASTErrorNonLinearResourceUnsupported,
    OXMVASTErrorGenericCompanionError = 600,
    OXMVASTErrorCompanionDimensions,
    OXMVASTErrorRequiredCompanionUnavailable,
    OXMVASTErrorCompanionMediaNotFound,
    OXMVASTErrorCompanionResourceUnsupported,
    OXMVASTErrorUndefinedError = 900
};
