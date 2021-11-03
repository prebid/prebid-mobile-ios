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
@property (atomic, strong, nullable, readonly) BidResponseForRendering *lastBidResponse;
@property (atomic, strong, nullable, readonly) DemandResponseInfo *lastDemandResponseInfo;

// MARK: + (locks)
@property (nonatomic, strong, nonnull, readonly) NSObject *stateLockToken; /// guards 'bidRequester', 'lastResponse'' etc.

// MARK: - Lifecycle

- (instancetype)initWithConfigID:(NSString *)configID
             bidRequesterFactory:(PBMBidRequesterFactoryBlock)bidRequesterFactory
                winNotifierBlock:(PBMWinNotifierBlock)winNotifierBlock; // designated

@end

NS_ASSUME_NONNULL_END
