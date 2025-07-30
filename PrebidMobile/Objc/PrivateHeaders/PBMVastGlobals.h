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
