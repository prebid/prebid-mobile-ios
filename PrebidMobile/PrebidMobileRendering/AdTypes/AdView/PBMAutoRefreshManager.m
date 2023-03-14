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

#import "PBMAutoRefreshManager.h"

#import "PBMAdRefreshOptions.h"
#import "PBMFunctions+Private.h"

#import "PBMMacros.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif


@interface PBMAutoRefreshManager ()

/// Queue on which PBMAutoRefreshManager should acquire the lock protecting external state during refresh attempts.
@property (nonatomic, strong, nullable, readonly) dispatch_queue_t lockingQueue;
/// Block providing the lock protecting external state during refresh attempts
/// Provided entity will be locked on 'lockingQueue' and released after the refresh attempt on the Main Thread.
@property (nonatomic, copy, nullable, readonly) id<NSLocking> (^lockProvider)(void);

@property (nonatomic, assign, readonly) NSTimeInterval prefetchTime;

// Note: The following blocks are invoked on the Main Thread
@property (nonatomic, copy, nonnull, readonly) NSNumber * _Nullable (^refreshDelayBlock)(void);
@property (nonatomic, copy, nonnull, readonly) BOOL (^mayRefreshNowBlock)(void);
@property (nonatomic, copy, nonnull, readonly) void (^refreshBlock)(void);

/// Block currently scheduled for the execution
@property (nonatomic, strong) dispatch_block_t delayedBlock;
/// Lock enclosing operations of scheduling/cancellation of blocks and mutations of 'delayedBlock'
@property (nonatomic, strong, nonnull, readonly) NSLock *delayedBlockLock;

@end



@implementation PBMAutoRefreshManager

// MARK: - Lifecycle

- (instancetype)initWithPrefetchTime:(NSTimeInterval)prefetchTime
                        lockingQueue:(dispatch_queue_t)lockingQueue
                        lockProvider:(id<NSLocking> (^ _Nullable)(void))lockProvider
                   refreshDelayBlock:(NSNumber * _Nullable (^)(void))refreshDelayBlock
                  mayRefreshNowBlock:(BOOL (^)(void))mayRefreshNowBlock
                        refreshBlock:(void (^)(void))refreshBlock
{
    if (!(self = [super init])) {
        return nil;
    }
    _lockProvider = [lockProvider copy];
    _lockingQueue = lockingQueue;
    _prefetchTime = prefetchTime;
    _refreshDelayBlock = [refreshDelayBlock copy];
    _mayRefreshNowBlock = [mayRefreshNowBlock copy];
    _refreshBlock = [refreshBlock copy];
    _delayedBlockLock = [[NSLock alloc] init];
    return self;
}

// MARK: - Public Methods

/**
 Sets up refresh timer
 If refreshing is enabled, call `[self refresh]` in `[self getRefreshOptions].delay` seconds.
 If refreshing is disabled (either due to hitting the max or it never being enabled), bail and do nothing.
 */
- (void)setupRefreshTimer {
    PBMLogWhereAmI();
    
    //Bail if autorefresh is disabled or if the refresh max has been hit.
    PBMAdRefreshOptions *refreshOptions = [self getRefreshOptions];
    if (refreshOptions.type != PBMAdRefreshType_ReloadLater) {
        return;
    }
    
    NSTimeInterval refreshDelay = refreshOptions.delay;
    PBMLogInfo(@"Will load another ad in %ld seconds", (long) refreshDelay);
    
    NSLock * const lock = self.delayedBlockLock;
    [lock lock];
    
    //If we're already waiting on a refresh, cancel it.
    [self cancelDelayedBlock];
    
    dispatch_queue_t destinationQueue = nil;
    dispatch_block_t rawDestinationBlock = nil;
    
    @weakify(self);
    if (self.lockProvider && self.lockingQueue) {
        destinationQueue = self.lockingQueue;
        rawDestinationBlock = ^{
            @strongify(self);
            if (!self) { return; }
            
            [self acquireLockAndRefresh];
        };
    } else {
        destinationQueue = dispatch_get_main_queue();
        rawDestinationBlock = ^{
            @strongify(self);
            if (!self) { return; }
            
            [self refresh];
        };
    }
    
    dispatch_block_t const destinationBlock = dispatch_block_create(0, rawDestinationBlock);
    
    self.delayedBlock = destinationBlock;
    dispatch_after([PBMFunctions dispatchTimeAfterTimeInterval:refreshDelay], destinationQueue, destinationBlock);
    
    [lock unlock];
}

- (void)cancelRefreshTimer {
    NSLock * const lock = self.delayedBlockLock;
    [lock lock];
    [self cancelDelayedBlock];
    [lock unlock];
}

// MARK: - Private Methods

- (void)acquireLockAndRefresh {
    NSLock * const delayedBlockLock = self.delayedBlockLock;
    [delayedBlockLock lock];
    id<NSLocking> const externalLock = self.lockProvider();
    [externalLock lock];
    @weakify(self);
    dispatch_block_t const newDelayedBlockRaw = ^{
        @strongify(self);
        if (!self) { return; }
        
        [self refresh];
        [externalLock unlock];
    };
    dispatch_block_t const newDelayedBlock = dispatch_block_create(0, newDelayedBlockRaw);
    self.delayedBlock = newDelayedBlock;
    dispatch_async(dispatch_get_main_queue(), newDelayedBlock);
    [delayedBlockLock unlock];
}

- (void)refresh {
    //Check to see if the current creative is invisible or "opened" (expanded, resized, or showing a clickThrough)
    //If it is then skip this load. In the second case we already have a pre-loaded transaction.
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    BOOL isBackground = state == UIApplicationStateBackground || state == UIApplicationStateInactive;
   
    if ( !isBackground && self.mayRefreshNowBlock()) {
        self.refreshBlock();
    } else {
        PBMLogInfo(@"Creative is invisible or opened. Skipping refresh.");
        [self setupRefreshTimer];
    }
}

// Note: calls to this method should be secured using 'delayedBlockLock'
- (void)cancelDelayedBlock {
    if (self.delayedBlock) {
        // Note: 'self.delayedBlock' must have been created with 'dispatch_block_create'
        dispatch_block_cancel(self.delayedBlock);
        self.delayedBlock = nil;
    }
}

// Determines refresh action and refresh delay according to the manager's state and properties of the current creative
- (PBMAdRefreshOptions *)getRefreshOptions {
    // if autoRefreshDelay is 0, then exit (i.e. don't start the refresh timers)
    NSNumber * const autoRefreshDelay = self.refreshDelayBlock();
    if (!autoRefreshDelay || autoRefreshDelay.doubleValue <= 0) {
        return [[PBMAdRefreshOptions alloc] initWithType:PBMAdRefreshType_StopWithRefreshDelay delay:0];
    }
    
    NSTimeInterval reloadTime = MAX(autoRefreshDelay.doubleValue - self.prefetchTime, 1.0);
    PBMLogInfo(@"Will load another ad in %fl seconds",reloadTime);
    
    return [[PBMAdRefreshOptions alloc] initWithType:PBMAdRefreshType_ReloadLater delay:reloadTime];
}

@end
