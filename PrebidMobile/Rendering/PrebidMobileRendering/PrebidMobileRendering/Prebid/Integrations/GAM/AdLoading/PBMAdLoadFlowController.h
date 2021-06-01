//
//  PBMAdLoadFlowController.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMAdLoadFlowControllerDelegate.h"
#import "PBMAdLoaderProtocol.h"
#import "PBMBidRequesterProtocol.h"

@class AdUnitConfig;
@class PrebidRenderingConfig;
@protocol PBMServerConnectionProtocol;

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

- (instancetype)initWithBidRequesterFactory:(id<PBMBidRequesterProtocol> (^)(AdUnitConfig *))bidRequesterFactory
                                   adLoader:(id<PBMAdLoaderProtocol>)adLoader
                                   delegate:(id<PBMAdLoadFlowControllerDelegate>)delegate
                      configValidationBlock:(PBMAdUnitConfigValidationBlock)configValidationBlock;

/// Starts new flow of loading the ad (if idle or failed) or continues previously paused flow
- (void)refresh;

/// Allows to update external state on the same serial dispatch queue as PBMAdLoadFlowController's state mutations.
/// 'mutationLock' is automatically locked before invoking the provided block, and unlocked afterwards.
- (void)enqueueGatedBlock:(nonnull dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
