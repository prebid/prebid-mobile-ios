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

#import "PBMAdLoadFlowController.h"

#import "PBMBidRequester.h"
#import "PBMAdLoadFlowState.h"
#import "PBMAdLoaderFlowDelegate.h"

@class BidResponse;
@protocol AdLoadFlowControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface PBMAdLoadFlowController () <PBMAdLoaderFlowDelegate>

@property (nonatomic, copy, nonnull, readonly) id<PBMBidRequesterProtocol> (^bidRequesterFactory)(AdUnitConfig *);
@property (nonatomic, strong, nonnull, readonly) id<PBMAdLoaderProtocol> adLoader;
@property (nonatomic, weak, nullable, readonly) id<AdLoadFlowControllerDelegate> delegate;
@property (nonatomic, copy, nonnull, readonly) PBMAdUnitConfigValidationBlock configValidationBlock;

@property (nonatomic, assign) PBMAdLoadFlowState flowState;
@property (nonatomic, copy, nullable) AdUnitConfig *savedAdUnitConfig;

// State: BidRequest
@property (nonatomic, strong, nullable) PBMBidRequester *bidRequester;
@property (nonatomic, strong, nullable) NSError *bidRequestError;

// State: PrimaryAdRequest
// _(no relevant properties)_

// State: LoadingDisplayView
@property (nonatomic, strong, nullable) id prebidAdObject; // Reused in ReadyToDeploy

// State: ReadyToDeploy
@property (nonatomic, strong, nullable) id primaryAdObject;
@property (nonatomic, strong, nullable) NSValue *adSize;

@end

NS_ASSUME_NONNULL_END
