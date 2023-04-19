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

#import "PBMAdLoaderProtocol.h"
#import "PBMBidRequesterProtocol.h"

@class AdUnitConfig;
@class Prebid;
@protocol PrebidServerConnectionProtocol;
@protocol AdLoadFlowControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^PBMAdUnitConfigValidationBlock)(AdUnitConfig *adUnitConfig, BOOL renderWithPrebid);

@interface PBMAdLoadFlowController : NSObject

/// Lock protecting the internal state of PBMAdLoadFlowController.
@property (nonatomic, strong, nonnull, readonly) NSLock *mutationLock;

/// Queue on which internal state of PBMAdLoadFlowController is mutated
@property (nonatomic, strong, nonnull, readonly) dispatch_queue_t dispatchQueue;

/// Whether the last ad loading attempt has failed and there is no current one.
/// Should only be access
@property (nonatomic, assign, readonly) BOOL hasFailedLoading;

// State: DemandReceived
@property (nonatomic, strong, nullable) BidResponse *bidResponse;

- (instancetype)initWithBidRequesterFactory:(id<PBMBidRequesterProtocol> (^)(AdUnitConfig *))bidRequesterFactory
                                   adLoader:(id<PBMAdLoaderProtocol>)adLoader
                                   delegate:(id<AdLoadFlowControllerDelegate>)delegate
                      configValidationBlock:(PBMAdUnitConfigValidationBlock)configValidationBlock;

/// Starts new flow of loading the ad (if idle or failed) or continues previously paused flow
- (void)refresh;

/// Allows to update external state on the same serial dispatch queue as PBMAdLoadFlowController's state mutations.
/// 'mutationLock' is automatically locked before invoking the provided block, and unlocked afterwards.
- (void)enqueueGatedBlock:(nonnull dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
