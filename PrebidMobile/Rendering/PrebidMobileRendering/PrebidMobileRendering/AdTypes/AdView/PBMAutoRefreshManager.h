//
//  PBMAutoRefreshManager.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBMAutoRefreshCountConfig.h"

@class PBMAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface PBMAutoRefreshManager : NSObject

- (instancetype)initWithPrefetchTime:(NSTimeInterval)prefetchTime
                        lockingQueue:(nullable dispatch_queue_t)lockingQueue
                        lockProvider:(_Nullable id<NSLocking> (^ _Nullable)(void))lockProvider
                   refreshDelayBlock:(NSNumber * _Nullable (^)(void))refreshDelayBlock
                  mayRefreshNowBlock:(BOOL (^)(void))mayRefreshNowBlock
                        refreshBlock:(void (^)(void))refreshBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)setupRefreshTimer;
- (void)cancelRefreshTimer;

@end

NS_ASSUME_NONNULL_END
