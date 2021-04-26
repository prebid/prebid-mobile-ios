//
//  PBMLocalResponseInfoCache.m
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMLocalResponseInfoCache.h"
#import "PBMLocalResponseInfoCache+Internal.h"

#import "PBMCachedResponseInfo.h"
#import "PBMWeakTimerTargetBox.h"


@interface PBMLocalResponseInfoCache ()
@property (nonatomic, strong, nonnull, readonly) NSMutableDictionary<NSString *, PBMCachedResponseInfo *> *cachedResponses;
@property (nonatomic, strong, nonnull, readonly) PBMScheduledTimerFactory scheduledTimerFactory;
@property (nonatomic, assign, readonly) NSTimeInterval expirationInterval;
@property (nonatomic, strong, nonnull, readonly) NSObject *cacheLock;
@end


@implementation PBMLocalResponseInfoCache

- (instancetype)initWithScheduledTimerFactory:(PBMScheduledTimerFactory)scheduledTimerFactory
                           expirationInterval:(NSTimeInterval)expirationInterval
{
    if (!(self = [super init])) {
        return nil;
    }
    _cachedResponses = [[NSMutableDictionary alloc] init];
    _scheduledTimerFactory = [PBMWeakTimerTargetBox
                              scheduledTimerFactoryWithWeakifiedTarget:[scheduledTimerFactory copy]];
    _expirationInterval = expirationInterval;
    _cacheLock = [[NSObject alloc] init];
    return self;
}

// MARK: - Internal API

- (NSString *)storeResponseInfo:(PBMDemandResponseInfo *)responseInfo {
    NSUUID * const uuid = [NSUUID UUID];
    NSString * const localCacheID = [NSString stringWithFormat:@"Prebid_%@", uuid.UUIDString];
    @synchronized (self.cacheLock) {
        id<PBMTimerInterface> const timer = [self scheduleExpirationTimerForID:localCacheID];
        PBMCachedResponseInfo * const cachedResponse = [[PBMCachedResponseInfo alloc] initWithResponseInfo:responseInfo
                                                                                           expirationTimer:timer];
        self.cachedResponses[localCacheID] = cachedResponse;
    }
    return localCacheID;
}

- (PBMDemandResponseInfo *)getStoredResponseInfo:(NSString *)localCacheID {
    return [self getAndRemoveCachedResponseInfo:localCacheID];
}

// MARK: - Private API

- (id<PBMTimerInterface>)scheduleExpirationTimerForID:(NSString *)localCacheID {
    return self.scheduledTimerFactory(self.expirationInterval,          // interval
                                      self,                             // target
                                      @selector(expireCachedResponse:), // selector
                                      localCacheID,                     // user info
                                      NO);                              // repeats
}

- (void)expireCachedResponse:(NSString *)localCacheID {
    PBMDemandResponseInfo * const expiredResponse = [self getAndRemoveCachedResponseInfo:localCacheID];
    [self notifyResponseInfoExpired:expiredResponse];
}

- (PBMDemandResponseInfo *)getAndRemoveCachedResponseInfo:(NSString *)localCacheID {
    PBMCachedResponseInfo *cachedEntry = nil;
    @synchronized (self.cacheLock) {
        cachedEntry = self.cachedResponses[localCacheID];
        [cachedEntry.expirationTimer invalidate];
        [self.cachedResponses removeObjectForKey:localCacheID];
    }
    return cachedEntry.responseInfo;
}

- (void)notifyResponseInfoExpired:(PBMDemandResponseInfo *)expiredResponseInfo {
    // TODO: Implement
}

@end
