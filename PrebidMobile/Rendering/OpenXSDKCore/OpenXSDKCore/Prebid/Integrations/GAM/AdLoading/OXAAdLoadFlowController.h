//
//  OXAAdLoadFlowController.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXAAdLoadFlowControllerDelegate.h"
#import "OXAAdLoaderProtocol.h"
#import "OXABidRequesterProtocol.h"

@class OXAAdUnitConfig;
@class OXASDKConfiguration;
@protocol OXMServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^OXAAdUnitConfigValidationBlock)(OXAAdUnitConfig *adUnitConfig, BOOL renderWithApollo);

@interface OXAAdLoadFlowController : NSObject

/// Lock protecting the internal state of OXAAdLoadFlowController.
@property (nonatomic, strong, nonnull, readonly) NSLock *mutationLock;

/// Queue on which internal state of OXAAdLoadFlowController is mutated
@property (nonatomic, strong, nonnull, readonly) dispatch_queue_t dispatchQueue;

/// Whether the last ad loading attempt has failed and there is no current one.
/// Should only be access
@property (nonatomic, assign, readonly) BOOL hasFailedLoading;

- (instancetype)initWithBidRequesterFactory:(id<OXABidRequesterProtocol> (^)(OXAAdUnitConfig *))bidRequesterFactory
                                   adLoader:(id<OXAAdLoaderProtocol>)adLoader
                                   delegate:(id<OXAAdLoadFlowControllerDelegate>)delegate
                      configValidationBlock:(OXAAdUnitConfigValidationBlock)configValidationBlock;

/// Starts new flow of loading the ad (if idle or failed) or continues previously paused flow
- (void)refresh;

/// Allows to update external state on the same serial dispatch queue as OXAAdLoadFlowController's state mutations.
/// 'mutationLock' is automatically locked before invoking the provided block, and unlocked afterwards.
- (void)enqueueGatedBlock:(nonnull dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
