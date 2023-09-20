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

@import Foundation;

#import "PBMAdMarkupStringHandler.h"
#import "PBMWinNotifierFactoryBlock.h"

@protocol PrebidServerConnectionProtocol;

NS_ASSUME_NONNULL_BEGIN


@interface PBMWinNotifier : NSObject

@property (nonatomic, class, readonly) PBMWinNotifierFactoryBlock factoryBlock;

+ (void)notifyThroughConnection:(id<PrebidServerConnectionProtocol>)connection
                     winningBid:(Bid *)bid
                       callback:(PBMAdMarkupStringHandler)adMarkupConsumer;

+ (PBMWinNotifierBlock)winNotifierBlockWithConnection:(id<PrebidServerConnectionProtocol>)connection;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
