//
//  OXABannerView.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import UIKit;

#import "OXABannerViewDelegate.h"
#import "OXAAdFormat.h"
#import "OXAAdPosition.h"
#import "OXAVideoPlacementType.h"

@protocol OXABannerEventHandler;
@class OXANativeAdConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface OXABannerView : UIView

@property (nonatomic, copy, readonly) NSString *configId;

@property (atomic, assign) NSTimeInterval refreshInterval;
@property (atomic, copy, nullable) NSArray<NSValue *> *additionalSizes;
@property (atomic) OXAAdFormat adFormat;
@property (atomic) OXAAdPosition adPosition;
@property (atomic, assign) OXAVideoPlacementType videoPlacementType;
@property (atomic, copy, nullable) OXANativeAdConfiguration *nativeAdConfig;

@property (atomic, weak, nullable) id<OXABannerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                     configId:(NSString *)configId
                       adSize:(CGSize)size
                 eventHandler:(id<OXABannerEventHandler>)eventHandler;

- (instancetype)initWithConfigId:(NSString *)configId
                    eventHandler:(id<OXABannerEventHandler>)eventHandler;

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
