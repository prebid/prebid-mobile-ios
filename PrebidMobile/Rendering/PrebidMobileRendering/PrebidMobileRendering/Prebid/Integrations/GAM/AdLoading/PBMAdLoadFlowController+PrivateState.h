//
//  PBMAdLoadFlowController+PrivateState.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMAdLoadFlowController.h"

#import "PBMAdUnitConfig.h"
#import "PBMBidRequester.h"
#import "PBMBidResponse.h"
#import "PBMAdLoadFlowState.h"
#import "PBMAdLoaderFlowDelegate.h"
#import "PBMBannerEventLoadingDelegate.h"
#import "PBMDisplayViewLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMAdLoadFlowController () <PBMAdLoaderFlowDelegate>

@property (nonatomic, copy, nonnull, readonly) id<PBMBidRequesterProtocol> (^bidRequesterFactory)(PBMAdUnitConfig *);
@property (nonatomic, strong, nonnull, readonly) id<PBMAdLoaderProtocol> adLoader;
@property (nonatomic, weak, nullable, readonly) id<PBMAdLoadFlowControllerDelegate> delegate;
@property (nonatomic, copy, nonnull, readonly) PBMAdUnitConfigValidationBlock configValidationBlock;

@property (nonatomic, assign) PBMAdLoadFlowState flowState;
@property (nonatomic, copy, nullable) PBMAdUnitConfig *savedAdUnitConfig;

// State: BidRequest
@property (nonatomic, strong, nullable) PBMBidRequester *bidRequester;
@property (nonatomic, strong, nullable) NSError *bidRequestError;

// State: DemandReceived
@property (nonatomic, strong, nullable) PBMBidResponse *bidResponse;

// State: PrimaryAdRequest
// _(no relevant properties)_

// State: LoadingDisplayView
@property (nonatomic, strong, nullable) id prebidAdObject; // Reused in ReadyToDeploy

// State: ReadyToDeploy
@property (nonatomic, strong, nullable) id primaryAdObject;
@property (nonatomic, strong, nullable) NSValue *adSize;

@end

NS_ASSUME_NONNULL_END
