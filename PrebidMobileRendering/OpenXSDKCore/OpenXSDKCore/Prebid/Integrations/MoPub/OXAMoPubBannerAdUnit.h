//
//  OXAMoPubBannerAdUnit.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;
@import UIKit;

#import "OXAFetchDemandResult.h"
#import "OXAAdFormat.h"
#import "OXAAdPosition.h"
#import "OXAVideoPlacementType.h"

@class OXANativeAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OXAMoPubBannerAdUnit : NSObject

@property (nonatomic, copy, readonly) NSString *configId;
@property (nonatomic, assign) NSTimeInterval refreshInterval;
@property (nonatomic, copy, nullable) NSArray<NSValue *> *additionalSizes;
@property (nonatomic) OXAAdFormat adFormat;
@property (atomic) OXAAdPosition adPosition;
@property (atomic, assign) OXAVideoPlacementType videoPlacementType;
@property (nonatomic, copy, nullable) OXANativeAdConfiguration *nativeAdConfig;

- (instancetype)initWithConfigId:(NSString *)configId size:(CGSize)size;

- (void)fetchDemandWithObject:(NSObject *)adObject completion:(void (^)(OXAFetchDemandResult))completion;
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
