//
//  OXMAutoRefreshManager.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMAutoRefreshCountConfig.h"

@class OXMAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OXMAutoRefreshManager : NSObject

- (instancetype)initWithPrefetchTime:(NSTimeInterval)prefetchTime
                        lockingQueue:(nullable dispatch_queue_t)lockingQueue
                        lockProvider:(id<NSLocking> (^ _Nullable)(void))lockProvider
                   refreshDelayBlock:(NSNumber * _Nullable (^)(void))refreshDelayBlock
                  mayRefreshNowBlock:(BOOL (^)(void))mayRefreshNowBlock
                        refreshBlock:(void (^)(void))refreshBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)setupRefreshTimer;
- (void)cancelRefreshTimer;

@end

NS_ASSUME_NONNULL_END
