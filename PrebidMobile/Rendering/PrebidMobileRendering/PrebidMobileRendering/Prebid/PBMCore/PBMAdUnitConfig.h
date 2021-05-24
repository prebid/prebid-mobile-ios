//
//  PBMAdUnitConfig.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import Foundation;
@import UIKit;


#import "PBMAdFormat.h"
#import "PBMAdPosition.h"
#import "PBMVideoPlacementType.h"

@class NativeAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT const NSTimeInterval PBMAdPrefetchTime;


@interface PBMAdUnitConfig : NSObject<NSCopying>

// MARK: Properties

@property (nonatomic, copy, readonly) NSString *configId;

@property (nonatomic, assign) PBMAdFormat adFormat;

@property (nonatomic, copy, nullable) NativeAdConfiguration *nativeAdConfig;

@property (nonatomic, strong, nullable, readonly) NSValue *adSize;
@property (nonatomic, copy, nullable) NSArray<NSValue *> *additionalSizes;
@property (nonatomic, strong, nullable) NSValue *minSizePerc;

@property (nonatomic, assign) BOOL isInterstitial;
@property (nonatomic, assign) BOOL isOptIn;

@property (nonatomic, assign) PBMAdPosition adPosition;
@property (nonatomic, assign) PBMVideoPlacementType videoPlacementType;

@property (nonatomic, assign) NSTimeInterval refreshInterval;


// MARK: Init

- (instancetype)initWithConfigId:(NSString *)configId;
- (instancetype)initWithConfigId:(NSString *)configId size:(CGSize)size;

// MARK: Methods

// Note: context data is stored with 'copy' semantics
- (void)addContextData:(NSString *)data
                forKey:(NSString *)key;

- (void)updateContextData:(NSSet<NSString *> *)data
                   forKey:(NSString *)key;

- (void)removeContextDataForKey:(NSString *)key;

- (void)clearContextData;

@end

NS_ASSUME_NONNULL_END
