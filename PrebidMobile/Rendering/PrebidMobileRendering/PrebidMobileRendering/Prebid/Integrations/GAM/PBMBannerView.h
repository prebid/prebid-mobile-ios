//
//  PBMBannerView.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import UIKit;

#import "PBMBannerViewDelegate.h"
#import "PBMAdFormat.h"
#import "PBMAdPosition.h"
#import "PBMVideoPlacementType.h"

@protocol PBMBannerEventHandler;
@class NativeAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface PBMBannerView : UIView

@property (nonatomic, copy, readonly) NSString *configId;

@property (atomic, assign) NSTimeInterval refreshInterval;
@property (atomic, copy, nullable) NSArray<NSValue *> *additionalSizes;
@property (atomic) PBMAdFormat adFormat;
@property (atomic) PBMAdPosition adPosition;
@property (atomic, assign) PBMVideoPlacementType videoPlacementType;
@property (atomic, copy, nullable) NativeAdConfiguration *nativeAdConfig;

@property (atomic, weak, nullable) id<PBMBannerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                     configId:(NSString *)configId
                       adSize:(CGSize)size
                 eventHandler:(id<PBMBannerEventHandler>)eventHandler;

- (instancetype)initWithConfigId:(NSString *)configId
                    eventHandler:(id<PBMBannerEventHandler>)eventHandler;

- (instancetype)initWithFrame:(CGRect)frame
                     configId:(NSString *)configId
                       adSize:(CGSize)size;

- (void)loadAd;
- (void)stopRefresh;

// MARK: - Context Data
// Note: context data is stored with 'copy' semantics
- (void)addContextData:(NSString *)data forKey:(NSString *)key;
- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key;
- (void)removeContextDataForKey:(NSString *)key;
- (void)clearContextData;

@end

NS_ASSUME_NONNULL_END
