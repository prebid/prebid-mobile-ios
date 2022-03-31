/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "PBMAdConfiguration.h"
#import "PBMConstants.h"
#import "PBMFunctions+Private.h"

#import "PrebidMobileSwiftHeaders.h"
#import <PrebidMobile/PrebidMobile-Swift.h>

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
        self.adFormats = [[NSSet alloc] initWithArray:@[AdFormat.display]];
        self.isInterstitialAd = NO;
        self.interstitialLayout = PBMInterstitialLayoutUndefined;
        self.isBuiltInVideo = NO;
        self.autoRefreshDelay = @(PBMAutoRefresh.AUTO_REFRESH_DELAY_DEFAULT);
        self.numRefreshes = 0;
        self.pollFrequency = 0.2;
        self.viewableArea = 1;
        self.viewableDuration = 0;
        self.videoPlacementType = PBMVideoPlacementType_Undefined;
        self.isMuted = YES;
        self.isSoundButtonVisible = NO;
        self.maxVideoDuration = PBMVideoConstants.DEFAULT_MAX_VIDEO_DURATION;
        self.closeButtonArea = PBMConstants.CLOSE_BUTTON_AREA_DEFAULT;
        self.closeButtonPosition = PositionTopRight;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[PBMAdConfiguration class]]) {
        return false;
    }
    
    BOOL res = true;
    
    PBMAdConfiguration *config = (PBMAdConfiguration *)object;
    
    res = res && (self.adFormats == config.adFormats);
    res = res && (self.videoPlacementType == config.videoPlacementType);

    return res;
}

+ (BOOL)nilEqualObject1:(id)lhs object2:(id)rhs {
    return (lhs == nil && rhs == nil) || [lhs isEqual:rhs];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    PBMAdConfiguration *config = [PBMAdConfiguration new];
    
    config.adFormats = self.adFormats;
    config.videoPlacementType = self.videoPlacementType;
    config.clickHandlerOverride = self.clickHandlerOverride;
    config.isMuted = self.isMuted;
    config.isSoundButtonVisible = self.isSoundButtonVisible;
    config.maxVideoDuration = self.maxVideoDuration;
    config.closeButtonArea = self.closeButtonArea;
    config.closeButtonPosition = self.closeButtonPosition;
    return config;
}

@end
