//
//  OXABaseAdUnit.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXANativeAdConfiguration.h"

#import "OXADemandResponseInfo.h"
#import "OXANativeAd.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OXAFetchDemandCompletionHandler)(OXADemandResponseInfo * _Nonnull demandResponseInfo);

@interface OXABaseAdUnit : NSObject

// MARK: - Required properties
@property (nonatomic, copy, readonly) NSString *configId;

// MARK: - Lifecycle
- (instancetype)init NS_UNAVAILABLE;

// MARK: - Ad Request
- (void)fetchDemandWithCompletion:(OXAFetchDemandCompletionHandler)completion;

// MARK: - Context Data
// Note: context data is stored with 'copy' semantics
- (void)addContextData:(NSString *)data forKey:(NSString *)key;
- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key;
- (void)removeContextDataForKey:(NSString *)key;
- (void)clearContextData;

@end

NS_ASSUME_NONNULL_END
