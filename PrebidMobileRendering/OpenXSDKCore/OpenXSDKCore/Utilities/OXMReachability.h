//
//  OXMReachability.h
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXANetworkType.h"

@class OXMReachability;

NS_ASSUME_NONNULL_BEGIN

typedef void (^OXMNetworkReachableBlock)(OXMReachability *reachability);

@interface OXMReachability : NSObject

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
- (void)onNetworkRestored:(nullable OXMNetworkReachableBlock)reachableBlock;

- (OXANetworkType)currentReachabilityStatus;

@end
NS_ASSUME_NONNULL_END
