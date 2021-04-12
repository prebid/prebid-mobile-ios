//
//  OXABaseAdUnit+Protected.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABaseAdUnit.h"

#import "OXAAdUnitConfig.h"
#import "OXABidRequesterFactoryBlock.h"
#import "OXABidResponse.h"
#import "OXASDKConfiguration.h"
#import "OXAWinNotifierBlock.h"
#import "OXMServerConnectionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXABaseAdUnit ()

// MARK: - Properties

// MARK: + (assigned on init)
@property (nonatomic, strong, nonnull, readonly) OXAAdUnitConfig *adUnitConfig;
@property (nonatomic, copy, nonnull, readonly) OXAWinNotifierBlock winNotifierBlock;

// MARK: + (updated on every BidRequester callback)
@property (atomic, strong, nullable, readonly) OXABidResponse *lastBidResponse;
@property (atomic, strong, nullable, readonly) OXADemandResponseInfo *lastDemandResponseInfo;

// MARK: + (locks)
@property (nonatomic, strong, nonnull, readonly) NSObject *stateLockToken; /// guards 'bidRequester', 'lastResponse'' etc.

// MARK: - Lifecycle

- (instancetype)initWithConfigID:(NSString *)configID
             bidRequesterFactory:(OXABidRequesterFactoryBlock)bidRequesterFactory
                winNotifierBlock:(OXAWinNotifierBlock)winNotifierBlock; // designated

@end

NS_ASSUME_NONNULL_END
