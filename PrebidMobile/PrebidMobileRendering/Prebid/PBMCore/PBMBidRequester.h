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

@class AdUnitConfig;
@class BidResponse;
@class Prebid;
@class Targeting;
@protocol PrebidServerConnectionProtocol;
@protocol PBMBidRequesterProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface PBMBidRequester : NSObject <PBMBidRequesterProtocol>

- (instancetype)initWithConnection:(id<PrebidServerConnectionProtocol>)connection
                  sdkConfiguration:(Prebid *)sdkConfiguration
                         targeting:(Targeting *)targeting
               adUnitConfiguration:(AdUnitConfig *)adUnitConfiguration;

- (void)requestBidsWithCompletion:(void (^)(BidResponse * _Nullable, NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
