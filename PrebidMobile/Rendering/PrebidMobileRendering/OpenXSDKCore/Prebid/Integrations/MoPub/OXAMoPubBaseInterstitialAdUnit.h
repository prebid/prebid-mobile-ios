//
//  OXAMoPubBaseInterstitialAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

#import "OXAFetchDemandResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAMoPubBaseInterstitialAdUnit : NSObject

@property (nonatomic, copy, readonly) NSString *configId;

- (instancetype)initWithConfigId:(NSString *)configId;

- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(OXAFetchDemandResult))completion;

// MARK: - Context Data
// Note: context data is stored with 'copy' semantics
- (void)addContextData:(NSString *)data forKey:(NSString *)key;
- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key;
- (void)removeContextDataForKey:(NSString *)key;
- (void)clearContextData;

@end

NS_ASSUME_NONNULL_END
