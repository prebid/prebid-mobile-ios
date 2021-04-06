//
//  OXMTransactionsCache+oxmTestExtension.h
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMTransactionsCache.h"

@interface OXMTransactionsCache ()

+ (NSString *)filePath;

@property (nonatomic, strong) NSMutableDictionary<OXMTransactionTag *, OXMTransaction *> *cache;
@property (nonatomic, readonly) NSTimeInterval expirationPeriod;

- (NSDate *)nextExpirationDate;
- (void)onExpirationFired;

@end
