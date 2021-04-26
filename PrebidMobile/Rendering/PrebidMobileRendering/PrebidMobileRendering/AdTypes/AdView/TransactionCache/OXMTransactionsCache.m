//
//  PBMTransactionsCache.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMTransactionsCache.h"
#import "PBMTransaction.h"
#import "PBMTransactionTag.h"
#import "PBMFunctions+Private.h"

#pragma mark - Constants

static NSTimeInterval const PBMExpirationInterval = 60 * 60; // 1 hour

#pragma mark - Private Interface

@interface PBMTransactionsCache ()

@property (nonatomic, strong) NSMutableDictionary<PBMTransactionTag *, PBMTransaction *> *cache;
@property (nonatomic, readonly) NSTimeInterval expirationPeriod; // The property is used for mocking in unit tests

@end

#pragma mark - Implementation

@implementation PBMTransactionsCache

+ (nonnull instancetype)singleton {
    static PBMTransactionsCache *singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [PBMTransactionsCache new];
    });
    
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cache = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)addTransaction:(PBMTransaction *)transaction {
    PBMTransactionTag *tag = [[PBMTransactionTag alloc] initWithAdConfiguration:transaction.adConfiguration];
    tag.expirationDate = [NSDate dateWithTimeIntervalSinceNow:self.expirationPeriod];
    
    if (self.cache.count == 0) {
        [self startExpirationTimer];
    }
    
    self.cache[tag] = transaction;
}

- (PBMTransaction *)extractTransactionForConfiguration:(PBMAdConfiguration *)adConfiguration {
    PBMTransactionTag *tag = [[PBMTransactionTag alloc] initWithAdConfiguration:adConfiguration];

    PBMTransaction *transaction = self.cache[tag];
    
    if (transaction) {
        [self.cache removeObjectForKey:tag];
    }
    
    return transaction;
}

- (void)clear {
    [self.cache removeAllObjects];
}

#pragma mark - Internal Methods

- (NSArray<PBMTransactionTag *> *)tags {
    return [self.cache allKeys];
}

#pragma mark - Expiration Methods

- (NSTimeInterval)expirationPeriod {
    return PBMExpirationInterval;
}

- (void)startExpirationTimer {
    [self startExpirationTimer:self.expirationPeriod];
}

- (void)onExpirationFired {
    NSDate *currentDate = [NSDate date];
    for (PBMTransactionTag *tag in self.tags) {
        NSComparisonResult datesComparisionResult = [tag.expirationDate compare:currentDate];
        if (datesComparisionResult == NSOrderedAscending || datesComparisionResult == NSOrderedSame) {
            [self.cache removeObjectForKey:tag];
        }
        else {
            continue;
        }
    }
    
    // Calculate the nearest expiration date and start the timer is needed.
    NSDate *nextExpirationDate = [self nextExpirationDate];
    if (nextExpirationDate) {
        [self startExpirationTimer:[nextExpirationDate timeIntervalSinceDate:currentDate]];
    }
}

- (void)startExpirationTimer:(NSTimeInterval)timeInterval {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self onExpirationFired];
    });
}

- (NSDate *)nextExpirationDate {
    if (!self.cache.count) {
        return nil;
    }
    
    // Sort tags by expiration date and return the earliest one.
    NSArray<PBMTransactionTag *> *sorted = [self.tags sortedArrayUsingComparator:^NSComparisonResult(PBMTransactionTag *obj1, PBMTransactionTag *obj2) {
        return [obj1.expirationDate compare:obj2.expirationDate];
    }];
    
    return sorted.firstObject.expirationDate;
}

@end
