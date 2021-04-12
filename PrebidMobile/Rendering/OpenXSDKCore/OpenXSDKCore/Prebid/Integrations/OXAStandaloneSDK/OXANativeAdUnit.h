//
//  OXANativeAdUnit.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXABaseAdUnit.h"

#import "OXANativeAdConfiguration.h"
#import "OXANativeAd.h"
#import "OXANativeAdHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAdUnit : OXABaseAdUnit

// MARK: - Required properties
@property (nonatomic, copy, readonly) NSString *configId; // inherited from OXABaseAdUnit
@property (atomic, copy, readonly) OXANativeAdConfiguration *nativeAdConfig;

// MARK: - Lifecycle
- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(OXANativeAdConfiguration *)nativeAdConfiguration;

// MARK: - Get Native Ad
- (void)fetchDemandWithCompletion:(OXAFetchDemandCompletionHandler)completion;  // inherited from OXABaseAdUnit

@end

NS_ASSUME_NONNULL_END
