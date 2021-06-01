//
//  PBMBaseAdUnit+Protected.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBaseAdUnit.h"

#import "PBMBidRequesterFactoryBlock.h"
#import "PBMWinNotifierBlock.h"
#import "PBMServerConnectionProtocol.h"

@class BidResponse;

NS_ASSUME_NONNULL_BEGIN

@interface PBMBaseAdUnit ()

// MARK: - Properties

// MARK: + (assigned on init)
@property (nonatomic, strong, nonnull, readonly) AdUnitConfig *adUnitConfig;
@property (nonatomic, copy, nonnull, readonly) PBMWinNotifierBlock winNotifierBlock;

// MARK: + (updated on every BidRequester callback)
@property (atomic, strong, nullable, readonly) BidResponse *lastBidResponse;
@property (atomic, strong, nullable, readonly) DemandResponseInfo *lastDemandResponseInfo;

// MARK: + (locks)
@property (nonatomic, strong, nonnull, readonly) NSObject *stateLockToken; /// guards 'bidRequester', 'lastResponse'' etc.

// MARK: - Lifecycle

- (instancetype)initWithConfigID:(NSString *)configID
             bidRequesterFactory:(PBMBidRequesterFactoryBlock)bidRequesterFactory
                winNotifierBlock:(PBMWinNotifierBlock)winNotifierBlock; // designated

@end

NS_ASSUME_NONNULL_END
