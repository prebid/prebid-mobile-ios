//
//  MPReachabilityManager.h
//  MoPubSDK
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPReachability.h"

/**
 Provides a singleton interface for `MPReachability` since creating new
 instances of `MPReachability` is an expensive operation.
 */
@interface MPReachabilityManager : NSObject

/**
 Current network status.
 */
@property (nonatomic, readonly) MPNetworkStatus currentStatus;

/**
 Singleton instance of the manager.
 */
+ (instancetype _Nonnull)sharedManager;

/**
 Starts monitoring for changes in connectivity.
 */
- (void)startMonitoring;

/**
 Stops monitoring for changes in connectivity.
 */
- (void)stopMonitoring;

@end
