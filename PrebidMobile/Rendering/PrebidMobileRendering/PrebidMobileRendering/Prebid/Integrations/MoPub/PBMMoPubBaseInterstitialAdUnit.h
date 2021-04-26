//
//  PBMMoPubBaseInterstitialAdUnit.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

#import "PBMFetchDemandResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMMoPubBaseInterstitialAdUnit : NSObject

@property (nonatomic, copy, readonly) NSString *configId;

- (instancetype)initWithConfigId:(NSString *)configId;

- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(PBMFetchDemandResult))completion;

// MARK: - Context Data
// Note: context data is stored with 'copy' semantics
- (void)addContextData:(NSString *)data forKey:(NSString *)key;
- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key;
- (void)removeContextDataForKey:(NSString *)key;
- (void)clearContextData;

@end

NS_ASSUME_NONNULL_END
