//
//  OXAMoPubNativeAdUnit.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

#import "OXAFetchDemandResult.h"

@class OXANativeAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OXAMoPubNativeAdUnit : NSObject

@property (nonatomic, copy, readonly) NSString *configId;
@property (atomic, copy, readonly) OXANativeAdConfiguration *nativeAdConfig;

// MARK: - Lifecycle
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(OXANativeAdConfiguration *)nativeAdConfiguration;

// MARK: - Ad Request
- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(OXAFetchDemandResult))completion;

// MARK: - Context Data
// Note: context data is stored with 'copy' semantics
- (void)addContextData:(NSString *)data forKey:(NSString *)key;
- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key;
- (void)removeContextDataForKey:(NSString *)key;
- (void)clearContextData;

@end

NS_ASSUME_NONNULL_END
