//
//  OXAAdLoadFlowController+PrivateState.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAAdLoadFlowController.h"

#import "OXAAdUnitConfig.h"
#import "OXABidRequester.h"
#import "OXABidResponse.h"
#import "OXAAdLoadFlowState.h"
#import "OXAAdLoaderFlowDelegate.h"
#import "OXABannerEventLoadingDelegate.h"
#import "OXADisplayViewLoadingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAAdLoadFlowController () <OXAAdLoaderFlowDelegate>

@property (nonatomic, copy, nonnull, readonly) id<OXABidRequesterProtocol> (^bidRequesterFactory)(OXAAdUnitConfig *);
@property (nonatomic, strong, nonnull, readonly) id<OXAAdLoaderProtocol> adLoader;
@property (nonatomic, weak, nullable, readonly) id<OXAAdLoadFlowControllerDelegate> delegate;
@property (nonatomic, copy, nonnull, readonly) OXAAdUnitConfigValidationBlock configValidationBlock;

@property (nonatomic, assign) OXAAdLoadFlowState flowState;
@property (nonatomic, copy, nullable) OXAAdUnitConfig *savedAdUnitConfig;

// State: BidRequest
@property (nonatomic, strong, nullable) OXABidRequester *bidRequester;
@property (nonatomic, strong, nullable) NSError *bidRequestError;

// State: DemandReceived
@property (nonatomic, strong, nullable) OXABidResponse *bidResponse;

// State: PrimaryAdRequest
// _(no relevant properties)_

// State: LoadingDisplayView
@property (nonatomic, strong, nullable) id apolloAdObject; // Reused in ReadyToDeploy

// State: ReadyToDeploy
@property (nonatomic, strong, nullable) id primaryAdObject;
@property (nonatomic, strong, nullable) NSValue *adSize;

@end

NS_ASSUME_NONNULL_END
