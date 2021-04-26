//
//  PBMAdConfiguration.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "PBMAdConfiguration.h"
#import "PBMConstants.h"
#import "PBMFunctions+Private.h"

#pragma mark - PBMAdConfiguration

@implementation PBMAdConfiguration

/*
static NSString * const PBMSSCKeyAdKind = @"ad_kind";
static NSString * const PBMSSCKeyVideo = @"video";
static NSString * const PBMSSCKeyAdUnitID = @"ad_unit_id";
static NSString * const PBMSSCKeyAdGroupID = @"ad_unit_group_id";
static NSString * const PBMSSCKeyDomain = @"domain";
static NSString * const PBMSSCKeyPreload = @"preload";
static NSString * const PBMSSCKeyVideoSkipOffset = @"video_skip_offset";
static NSString * const PBMSSCKeyInterstitialLayout = @"interstitial_layout";
static NSString * const PBMSSCKeyPortrait = @"portrait";
static NSString * const PBMSSCKeyLandscape = @"landscape";
static NSString * const PBMSSCKeyRotatable = @"rotatable";
*/
#pragma mark - Properties

@synthesize autoRefreshDelay = _autoRefreshDelay;
@synthesize autoRefreshMax = _autoRefreshMax;
@synthesize numRefreshes = _numRefreshes;

- (void)setAutoRefreshDelay:(NSNumber *)autoRefreshDelay {
    if (autoRefreshDelay && [autoRefreshDelay floatValue] > 0) {
        NSTimeInterval clampedValue = [PBMFunctions clampAutoRefresh:autoRefreshDelay.doubleValue];
        _autoRefreshDelay = @(clampedValue);
    } else {
        _autoRefreshDelay = nil;
    }
}

- (NSNumber *)autoRefreshDelay {
    return !self.presentAsInterstitial ? _autoRefreshDelay : nil;
}

- (BOOL)presentAsInterstitial {
    NSNumber * const overrideValue = self.forceInterstitialPresentation;
    const BOOL rawValue = self.isInterstitialAd;
    return overrideValue ? overrideValue.boolValue : rawValue;
}

#pragma mark - Initialization

- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        self.adFormat = PBMAdFormatDisplayInternal;
        self.isNative = NO;
        self.isInterstitialAd = NO;
        self.interstitialLayout = PBMInterstitialLayoutUndefined;
        self.isBuiltInVideo = NO;
        self.autoRefreshDelay = @(PBMAutoRefresh.AUTO_REFRESH_DELAY_DEFAULT);
        self.numRefreshes = 0;
        self.pollFrequency = 0.2;
        self.viewableArea = 1;
        self.viewableDuration = 0;
        self.videoPlacementType = PBMVideoPlacementType_Undefined;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[PBMAdConfiguration class]]) {
        return false;
    }
    
    BOOL res = true;
    
    PBMAdConfiguration *config = (PBMAdConfiguration *)object;
    
    res = res && (self.adFormat == config.adFormat);
    res = res && (self.isNative == config.isNative);
    res = res && (self.videoPlacementType == config.videoPlacementType);

    return res;
}

+ (BOOL)nilEqualObject1:(id)lhs object2:(id)rhs {
    return (lhs == nil && rhs == nil) || [lhs isEqual:rhs];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    PBMAdConfiguration *config = [PBMAdConfiguration new];
    
    config.adFormat = self.adFormat;
    config.isNative = self.isNative;
    config.videoPlacementType = self.videoPlacementType;
    config.clickHandlerOverride = self.clickHandlerOverride;
    
    return config;
}

@end
