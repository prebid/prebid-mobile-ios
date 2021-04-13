//
//  OXAWinNotifier.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

#import "OXAAdMarkupStringHandler.h"
#import "OXAWinNotifierFactoryBlock.h"

NS_ASSUME_NONNULL_BEGIN


@interface OXAWinNotifier : NSObject

@property (nonatomic, class, readonly) OXAWinNotifierFactoryBlock factoryBlock;

+ (void)notifyThroughConnection:(id<OXMServerConnectionProtocol>)connection
                     winningBid:(OXABid *)bid
                       callback:(OXAAdMarkupStringHandler)adMarkupConsumer;

+ (OXAWinNotifierBlock)winNotifierBlockWithConnection:(id<OXMServerConnectionProtocol>)connection;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
