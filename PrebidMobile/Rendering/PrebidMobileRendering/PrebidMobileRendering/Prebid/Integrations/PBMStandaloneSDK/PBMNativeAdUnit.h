//
//  PBMNativeAdUnit.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMBaseAdUnit.h"

#import "PBMNativeAdConfiguration.h"
#import "PBMNativeAd.h"
#import "PBMNativeAdHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAdUnit : PBMBaseAdUnit

// MARK: - Required properties
@property (nonatomic, copy, readonly) NSString *configId; // inherited from PBMBaseAdUnit
@property (atomic, copy, readonly) PBMNativeAdConfiguration *nativeAdConfig;

// MARK: - Lifecycle
- (instancetype)initWithConfigID:(NSString *)configID
           nativeAdConfiguration:(PBMNativeAdConfiguration *)nativeAdConfiguration;

// MARK: - Get Native Ad
- (void)fetchDemandWithCompletion:(PBMFetchDemandCompletionHandler)completion;  // inherited from PBMBaseAdUnit

@end

NS_ASSUME_NONNULL_END
