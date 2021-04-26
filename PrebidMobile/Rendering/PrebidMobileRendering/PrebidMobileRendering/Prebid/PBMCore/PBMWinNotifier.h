//
//  PBMWinNotifier.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

#import "PBMAdMarkupStringHandler.h"
#import "PBMWinNotifierFactoryBlock.h"

NS_ASSUME_NONNULL_BEGIN


@interface PBMWinNotifier : NSObject

@property (nonatomic, class, readonly) PBMWinNotifierFactoryBlock factoryBlock;

+ (void)notifyThroughConnection:(id<PBMServerConnectionProtocol>)connection
                     winningBid:(PBMBid *)bid
                       callback:(PBMAdMarkupStringHandler)adMarkupConsumer;

+ (PBMWinNotifierBlock)winNotifierBlockWithConnection:(id<PBMServerConnectionProtocol>)connection;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
