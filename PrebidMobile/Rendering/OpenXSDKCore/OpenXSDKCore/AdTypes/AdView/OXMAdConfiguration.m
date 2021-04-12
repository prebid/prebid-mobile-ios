//
//  OXMAdConfiguration.m
//  OpenXSDKCore
//
//  Copyright © 2018 OpenX. All rights reserved.
//

#import "OXMAdConfiguration.h"
#import "OXMConstants.h"
#import "OXMFunctions+Private.h"

#pragma mark - OXMAdConfiguration

@implementation OXMAdConfiguration

static NSString * const OXMSSCKeyAdKind = @"ad_kind";
static NSString * const OXMSSCKeyVideo = @"video";
static NSString * const OXMSSCKeyAdUnitID = @"ad_unit_id";
static NSString * const OXMSSCKeyAdGroupID = @"ad_unit_group_id";
static NSString * const OXMSSCKeyDomain = @"domain";
static NSString * const OXMSSCKeyPreload = @"preload";
static NSString * const OXMSSCKeyVideoSkipOffset = @"video_skip_offset";
static NSString * const OXMSSCKeyInterstitialLayout = @"interstitial_layout";
static NSString * const OXMSSCKeyPortrait = @"portrait";
static NSString * const OXMSSCKeyLandscape = @"landscape";
static NSString * const OXMSSCKeyRotatable = @"rotatable";

#pragma mark - Properties

@synthesize autoRefreshDelay = _autoRefreshDelay;
@synthesize autoRefreshMax = _autoRefreshMax;
@synthesize numRefreshes = _numRefreshes;

- (void)setAutoRefreshDelay:(NSNumber *)autoRefreshDelay {
    if (autoRefreshDelay && [autoRefreshDelay floatValue] > 0) {
        NSTimeInterval clampedValue = [OXMFunctions clampAutoRefresh:autoRefreshDelay.doubleValue];
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
        self.adFormat = OXMAdFormatDisplay;
        self.isNative = NO;
        self.isInterstitialAd = NO;
        self.interstitialLayout = OXMInterstitialLayoutUndefined;
        self.isBuiltInVideo = NO;
        self.autoRefreshDelay = @(OXMAutoRefresh.AUTO_REFRESH_DELAY_DEFAULT);
        self.numRefreshes = 0;
        self.pollFrequency = 0.2;
        self.viewableArea = 1;
        self.viewableDuration = 0;
        self.videoPlacementType = OXAVideoPlacementType_Undefined;
    }
    
    return self;
}

- (instancetype)initFromSSCDict:(NSDictionary *)dict {
    self = [self init];
    if (self) {
        NSString *adFormat = dict[OXMSSCKeyAdKind];
        self.adFormat = [adFormat isEqualToString:OXMSSCKeyVideo] ? OXMAdFormatVideo : OXMAdFormatDisplay;
        NSString *interstitialLayout = dict[OXMSSCKeyInterstitialLayout];
        if (interstitialLayout && interstitialLayout.length > 0) {
            self.isInterstitialAd = YES;
            self.interstitialLayout = [self calculateLayoutFromString:interstitialLayout];
        }
    }
    
    return self;
}

- (OXMInterstitialLayout)calculateLayoutFromString:(NSString *)string {
    NSArray *interstitialTypes = @[OXMSSCKeyPortrait, OXMSSCKeyLandscape, OXMSSCKeyRotatable];
    NSUInteger item = [interstitialTypes indexOfObject:string];
    switch (item) {
        case 0:
            return OXMInterstitialLayoutPortrait;
        case 1:
            return OXMInterstitialLayoutLandscape;
        case 2:
            return OXMInterstitialLayoutAspectRatio;
        default:
            return OXMInterstitialLayoutUndefined;
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[OXMAdConfiguration class]]) {
        return false;
    }
    
    BOOL res = true;
    
    OXMAdConfiguration *config = (OXMAdConfiguration *)object;
    
    res = res && (self.adFormat == config.adFormat);
    res = res && (self.isNative == config.isNative);
    res = res && (self.videoPlacementType == config.videoPlacementType);

    return res;
}

+ (BOOL)nilEqualObject1:(id)lhs object2:(id)rhs {
    return (lhs == nil && rhs == nil) || [lhs isEqual:rhs];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    OXMAdConfiguration *config = [OXMAdConfiguration new];
    
    config.adFormat = self.adFormat;
    config.isNative = self.isNative;
    config.videoPlacementType = self.videoPlacementType;
    config.clickHandlerOverride = self.clickHandlerOverride;
    
    return config;
}

@end
