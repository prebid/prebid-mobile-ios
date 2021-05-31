//
//  PBMBaseAdUnit.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;

@class DemandResponseInfo;
@class NativeAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

typedef void(^PBMFetchDemandCompletionHandler)(DemandResponseInfo * _Nonnull demandResponseInfo);

@interface PBMBaseAdUnit : NSObject

// MARK: - Required properties
@property (nonatomic, copy, readonly) NSString *configId;

// MARK: - Lifecycle
- (instancetype)init NS_UNAVAILABLE;

// MARK: - Ad Request
- (void)fetchDemandWithCompletion:(PBMFetchDemandCompletionHandler)completion;

// MARK: - Context Data
// Note: context data is stored with 'copy' semantics
- (void)addContextData:(NSString *)data forKey:(NSString *)key;
- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key;
- (void)removeContextDataForKey:(NSString *)key;
- (void)clearContextData;

@end

NS_ASSUME_NONNULL_END
