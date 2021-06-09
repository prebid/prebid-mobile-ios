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
#import "PBMNetworkType.h"

@class PBMReachability;

NS_ASSUME_NONNULL_BEGIN

typedef void (^PBMNetworkReachableBlock)(PBMReachability *reachability);

@interface PBMReachability : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (nullable instancetype)reachabilityForInternetConnection;

/**
 * Singleton instance for checking whether the default route is available.
 */
+ (instancetype)singleton;

/**
 * Returns true is network is reachable otherwise returns false
 */
- (BOOL)isNetworkReachable;

/**
 * Starts monitoring of the network status.
 * Calls the reachableBlock when network is restored
 */
- (void)onNetworkRestored:(nullable PBMNetworkReachableBlock)reachableBlock;

- (PBMNetworkType)currentReachabilityStatus;

@end
NS_ASSUME_NONNULL_END
