//
//  PBMMoPubBannerAdUnit.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;
@import UIKit;

#import "PBMFetchDemandResult.h"
#import "PBMAdFormat.h"
#import "PBMAdPosition.h"
#import "PBMVideoPlacementType.h"

@class PBMNativeAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface PBMMoPubBannerAdUnit : NSObject

@property (nonatomic, copy, readonly) NSString *configId;
@property (nonatomic, assign) NSTimeInterval refreshInterval;
@property (nonatomic, copy, nullable) NSArray<NSValue *> *additionalSizes;
@property (nonatomic) PBMAdFormat adFormat;
@property (atomic) PBMAdPosition adPosition;
@property (atomic, assign) PBMVideoPlacementType videoPlacementType;
@property (nonatomic, copy, nullable) PBMNativeAdConfiguration *nativeAdConfig;

- (instancetype)initWithConfigId:(NSString *)configId size:(CGSize)size;

- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(PBMFetchDemandResult))completion;
- (void)stopRefresh;
/**
 * Call this method when an ad object (MPAdView) fails to load an ad.
 * @param adObject The ad object sending the message.
 * @param error The error
 */
- (void)adObject:(NSObject *)adObject didFailToLoadAdWithError:(NSError *)error;

// MARK: - Context Data
// Note: context data is stored with 'copy' semantics
- (void)addContextData:(NSString *)data forKey:(NSString *)key;
- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key;
- (void)removeContextDataForKey:(NSString *)key;
- (void)clearContextData;

@end

NS_ASSUME_NONNULL_END
