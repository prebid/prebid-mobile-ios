//
//  OXMTransactionsCache.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMTransactionsCache.h"
#import "OXMTransaction.h"
#import "OXMTransactionTag.h"
#import "OXMFunctions+Private.h"

#pragma mark - Constants

static NSTimeInterval const OXMExpirationInterval = 60 * 60; // 1 hour

#pragma mark - Private Interface

@interface OXMTransactionsCache ()

@property (nonatomic, strong) NSMutableDictionary<OXMTransactionTag *, OXMTransaction *> *cache;
@property (nonatomic, readonly) NSTimeInterval expirationPeriod; // The property is used for mocking in unit tests

@end

#pragma mark - Implementation

@implementation OXMTransactionsCache

+ (nonnull instancetype)singleton {
    static OXMTransactionsCache *singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [OXMTransactionsCache new];
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

- (void)addTransaction:(OXMTransaction *)transaction {
    OXMTransactionTag *tag = [[OXMTransactionTag alloc] initWithAdConfiguration:transaction.adConfiguration];
    tag.expirationDate = [NSDate dateWithTimeIntervalSinceNow:self.expirationPeriod];
    
    if (self.cache.count == 0) {
        [self startExpirationTimer];
    }
    
    self.cache[tag] = transaction;
}

- (OXMTransaction *)extractTransactionForConfiguration:(OXMAdConfiguration *)adConfiguration {
    OXMTransactionTag *tag = [[OXMTransactionTag alloc] initWithAdConfiguration:adConfiguration];

    OXMTransaction *transaction = self.cache[tag];
    
    if (transaction) {
        [self.cache removeObjectForKey:tag];
    }
    
    return transaction;
}

- (void)clear {
    [self.cache removeAllObjects];
}

#pragma mark - Internal Methods

- (NSArray<OXMTransactionTag *> *)tags {
    return [self.cache allKeys];
}

#pragma mark - Expiration Methods

- (NSTimeInterval)expirationPeriod {
    return OXMExpirationInterval;
}

- (void)startExpirationTimer {
    [self startExpirationTimer:self.expirationPeriod];
}

- (void)onExpirationFired {
    NSDate *currentDate = [NSDate date];
    for (OXMTransactionTag *tag in self.tags) {
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
    NSArray<OXMTransactionTag *> *sorted = [self.tags sortedArrayUsingComparator:^NSComparisonResult(OXMTransactionTag *obj1, OXMTransactionTag *obj2) {
        return [obj1.expirationDate compare:obj2.expirationDate];
    }];
    
    return sorted.firstObject.expirationDate;
}

@end
