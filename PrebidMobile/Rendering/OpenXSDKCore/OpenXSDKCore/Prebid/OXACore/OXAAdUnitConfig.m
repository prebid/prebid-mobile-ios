//
//  OXAAdUnitConfig.m
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import "OXAAdUnitConfig.h"
#import "OXAAdUnitConfig+Internal.h"

#import "OXANativeAdConfiguration.h"
#import "OXMAdConfiguration.h"

#import "OXMMacros.h"


static const NSTimeInterval OXAMinRefreshInterval = 15;
static const NSTimeInterval OXAMaxRefreshInterval = 120;
static const NSTimeInterval OXADefaultRefreshInterval = 60;

const NSTimeInterval OXAAdPrefetchTime = 3;


@interface OXAAdUnitConfig ()

@property (nonatomic, strong, readonly, nonnull) NSMutableDictionary<NSString *, NSMutableSet<NSString *> *> *extensionData;
@property (nonatomic, strong, nullable) NSMutableArray<NSValue *> *sizes;

@end


@implementation OXAAdUnitConfig

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
    _refreshInterval = OXADefaultRefreshInterval;
    
    _adConfiguration = [[OXMAdConfiguration alloc] init];
    _adConfiguration.autoRefreshDelay = @(0); // disable auto-refresh by AdViewManager
    
    if (size) {
        _adConfiguration.size = size.CGSizeValue;
    }
    
    _adPosition = OXAAdPosition_Undefined;
    
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
    OXAAdUnitConfig * const clone = [[OXAAdUnitConfig alloc] initWithConfigId:self.configId
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
    if (self.adFormat == OXAAdFormatVideo) {
        OXMLogWarn(@"'refreshInterval' property is not assignable for Outstream Video ads");
        return;
    }
    
    if (refreshInterval <= 0) { // no refresh
        _refreshInterval = 0;
    } else {
        const NSTimeInterval lowerClamped = MAX(refreshInterval, OXAMinRefreshInterval);
        const NSTimeInterval doubleClamped = MIN(lowerClamped, OXAMaxRefreshInterval);
        
        _refreshInterval = doubleClamped;
        
        if (refreshInterval != _refreshInterval) {
            OXMLogWarn(@"The value %.1f is out of range [%.1f;%.1f]. The value %.1f will be used",
                       refreshInterval, OXAMinRefreshInterval, OXAMaxRefreshInterval, _refreshInterval);
        }
    }
}

// MARK: - Proxied properties

- (OXMAdFormat)internalAdFormat {
    if (self.nativeAdConfig) {
        return OXMAdFormatNative;
    } else {
        return (OXMAdFormat) self.adFormat;
    }
}

- (void)setAdFormat:(OXAAdFormat)adFormat {
    _adFormat = adFormat;
    [self updateAdFormat];
}

- (void)setNativeAdConfig:(OXANativeAdConfiguration *)nativeAdConfig {
    _nativeAdConfig = [nativeAdConfig copy];
    self.adConfiguration.isNative = nativeAdConfig != nil;
    [self updateAdFormat];
}

- (void)updateAdFormat {
    const OXMAdFormat newAdFormat = self.internalAdFormat;
    if (self.adConfiguration.adFormat == newAdFormat) {
        return;
    }
    self.adConfiguration.adFormat = newAdFormat;
    self.refreshInterval = ((newAdFormat == OXMAdFormatVideo) ? 0 : OXADefaultRefreshInterval);
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

- (void)setVideoPlacementType:(OXAVideoPlacementType)videoPlacementType {
    self.adConfiguration.videoPlacementType = videoPlacementType;
}

- (OXAVideoPlacementType)videoPlacementType {
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
