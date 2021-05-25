//
//  PBMAdUnitConfig.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "PBMAdUnitConfig.h"
#import "PBMAdUnitConfig+Internal.h"

#import "PBMAdConfiguration.h"

#import "PBMMacros.h"

#import "PBMAdViewManagerDelegate.h"
#import "PBMDataAssetType.h"
#import "PBMPlayable.h"
#import "PBMJsonCodable.h"
#import "PBMNativeContextType.h"
#import "PBMNativeContextSubtype.h"
#import "PBMNativeEventType.h"
#import "PBMNativeEventTrackingMethod.h"
#import "PBMNativePlacementType.h"

#import "PBMBaseAdUnit.h"
#import "PBMBidRequesterFactoryBlock.h"
#import "PBMWinNotifierBlock.h"

#import "PBMImageAssetType.h"
#import "PBMNativeAdElementType.h"

#import "PBMBaseInterstitialAdUnit.h"
#import "PBMRewardedEventInteractionDelegate.h"

#import <PrebidMobileRendering/PrebidMobileRendering-Swift.h>


static const NSTimeInterval PBMMinRefreshInterval = 15;
static const NSTimeInterval PBMMaxRefreshInterval = 120;
static const NSTimeInterval PBMDefaultRefreshInterval = 60;

const NSTimeInterval PBMAdPrefetchTime = 3;


@interface PBMAdUnitConfig ()

@property (nonatomic, strong, readonly, nonnull) NSMutableDictionary<NSString *, NSMutableSet<NSString *> *> *extensionData;
@property (nonatomic, strong, nullable) NSMutableArray<NSValue *> *sizes;

@end


@implementation PBMAdUnitConfig

@synthesize refreshInterval = _refreshInterval;
@synthesize adFormat = _adFormat;
@synthesize nativeAdConfig = _nativeAdConfig;

// MARK: - Lifecycle

- (instancetype)initWithConfigId:(NSString *)configId adSize:(NSValue *)size {
    if (!(self = [super init])) {
        return nil;
    }
    _configId = [configId copy];
    _extensionData = [[NSMutableDictionary alloc] init];
    _adSize = size;
    _refreshInterval = PBMDefaultRefreshInterval;
    
    _adConfiguration = [[PBMAdConfiguration alloc] init];
    _adConfiguration.autoRefreshDelay = @(0); // disable auto-refresh by AdViewManager
    
    if (size) {
        _adConfiguration.size = size.CGSizeValue;
    }
    
    _adPosition = PBMAdPosition_Undefined;
    
    return self;
}

- (instancetype)initWithConfigId:(NSString *)configId {
    return (self = [self initWithConfigId:configId
                                   adSize:nil]);
}

- (instancetype)initWithConfigId:(NSString *)configId size:(CGSize)size {
    return (self = [self initWithConfigId:configId
                                   adSize:[NSValue valueWithCGSize:size]]);
}

- (id)copyWithZone:(NSZone *)zone {
    PBMAdUnitConfig * const clone = [[PBMAdUnitConfig alloc] initWithConfigId:self.configId
                                                                       adSize:self.adSize];
    clone.adFormat = self.adFormat;
    clone.adConfiguration.adFormat = self.adConfiguration.adFormat;
    clone.adConfiguration.isInterstitialAd = self.adConfiguration.isInterstitialAd;
    clone.adConfiguration.isOptIn = self.adConfiguration.isOptIn;
    clone.adConfiguration.videoPlacementType = self.adConfiguration.videoPlacementType;
    clone.nativeAdConfig = self.nativeAdConfig;
    clone.sizes = [self.sizes mutableCopy];
    clone.refreshInterval = self.refreshInterval;
    clone.minSizePerc = self.minSizePerc;
    [clone.extensionData addEntriesFromDictionary:self.extensionData];
    clone.adPosition = self.adPosition;
    
    return clone;
}

// MARK: - Computed properties

- (void)setAdditionalSizes:(NSArray<NSValue *> *)additionalSizes {
    if (self.sizes) {
        [self.sizes removeAllObjects];
    } else {
        self.sizes = [[NSMutableArray alloc] initWithCapacity:additionalSizes.count];
    }
    
    [self.sizes addObjectsFromArray:additionalSizes];
}

- (NSArray<NSValue *> *)additionalSizes {
    return self.sizes;
}

- (void)setRefreshInterval:(NSTimeInterval)refreshInterval {
    if (self.adFormat == PBMAdFormatVideo) {
        PBMLogWarn(@"'refreshInterval' property is not assignable for Outstream Video ads");
        return;
    }
    
    if (refreshInterval <= 0) { // no refresh
        _refreshInterval = 0;
    } else {
        const NSTimeInterval lowerClamped = MAX(refreshInterval, PBMMinRefreshInterval);
        const NSTimeInterval doubleClamped = MIN(lowerClamped, PBMMaxRefreshInterval);
        
        _refreshInterval = doubleClamped;
        
        if (refreshInterval != _refreshInterval) {
            PBMLogWarn(@"The value %.1f is out of range [%.1f;%.1f]. The value %.1f will be used",
                       refreshInterval, PBMMinRefreshInterval, PBMMaxRefreshInterval, _refreshInterval);
        }
    }
}

// MARK: - Proxied properties

- (PBMAdFormatInternal)internalAdFormat {
    if (self.nativeAdConfig) {
        return PBMAdFormatNativeInternal;
    } else {
        return (PBMAdFormatInternal) self.adFormat;
    }
}

- (void)setAdFormat:(PBMAdFormat)adFormat {
    _adFormat = adFormat;
    [self updateAdFormat];
}

- (void)setNativeAdConfig:(NativeAdConfiguration *)nativeAdConfig {
    _nativeAdConfig = [nativeAdConfig copy];
    self.adConfiguration.isNative = nativeAdConfig != nil;
    [self updateAdFormat];
}

- (void)updateAdFormat {
    const PBMAdFormatInternal newAdFormat = self.internalAdFormat;
    if (self.adConfiguration.adFormat == newAdFormat) {
        return;
    }
    self.adConfiguration.adFormat = newAdFormat;
    self.refreshInterval = ((newAdFormat == PBMAdFormatVideoInternal) ? 0 : PBMDefaultRefreshInterval);
}

- (void)setIsInterstitial:(BOOL)isInterstitial {
    self.adConfiguration.isInterstitialAd = isInterstitial;
}

- (BOOL)isInterstitial {
    return self.adConfiguration.isInterstitialAd;
}

- (void)setIsOptIn:(BOOL)isOptIn {
    self.adConfiguration.isOptIn = isOptIn;
}

- (BOOL)isOptIn {
    return self.adConfiguration.isOptIn;
}

- (void)setVideoPlacementType:(PBMVideoPlacementType)videoPlacementType {
    self.adConfiguration.videoPlacementType = videoPlacementType;
}

- (PBMVideoPlacementType)videoPlacementType {
    return self.adConfiguration.videoPlacementType;
}

// MARK: - Public Methods

- (void)addContextData:(NSString *)data forKey:(NSString *)key {
    NSMutableSet<NSString *> *dataSet = self.extensionData[key];
    if (dataSet == nil) {
        dataSet = [[NSMutableSet alloc] init];
        self.extensionData[key] = dataSet;
    }
    [dataSet addObject:[data copy]];
}

- (void)updateContextData:(NSSet<NSString *> *)data forKey:(NSString *)key {
    NSMutableSet<NSString *> * const newValue = data ? [[NSMutableSet alloc] initWithSet:data copyItems:YES] : nil;
    self.extensionData[key] = newValue;
}

- (void)removeContextDataForKey:(NSString *)key {
    self.extensionData[key] = nil;
}

- (void)clearContextData {
    [self.extensionData removeAllObjects];
}

- (NSDictionary<NSString *, NSArray<NSString *> *> *)contextDataDictionary {
    NSMutableDictionary<NSString *, NSArray<NSString *> *> * const result = [[NSMutableDictionary alloc] init];
    [self.extensionData enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key,
                                                     NSSet<NSString *> * _Nonnull obj,
                                                     BOOL * _Nonnull stop)
    {
        result[key] = obj.allObjects;
    }];

    return result;
}

@end
