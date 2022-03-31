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

@import UIKit;

#import "PBMCreativeClickHandlerBlock.h"
#import "PBMVideoPlacementType.h"
#import "PBMAutoRefreshCountConfig.h"
#import "PBMInterstitialLayout.h"
#import "PBMInterstitialDisplayProperties.h"

@class AdFormat;

/**
 Contains all the data needed to load an ad.
 */
NS_ASSUME_NONNULL_BEGIN

@interface PBMAdConfiguration : NSObject<PBMAutoRefreshCountConfig>

#pragma mark - Request

@property (nonatomic, strong) NSSet<AdFormat *> *adFormats;

/**
 Placement type for the video.
 */
@property (nonatomic, assign) PBMVideoPlacementType videoPlacementType;


#pragma mark - Interstitial

/**
 Whether or not this ad configuration is intended to represent an intersitial ad.

 Setting this to @c YES will disable auto refresh.
 */
@property (nonatomic, assign) BOOL isInterstitialAd;

/**
 Whether or not this ad configuration is intended to represent an ad as an intersitial one (regardless of original designation).
 Overrides `isInterstitialAd`

 Setting this to @c YES will disable auto refresh.
 */
@property (nonatomic, strong, nullable) NSNumber *forceInterstitialPresentation;

/**
 Whether or not this ad configuration is intended to represent an intersitial ad.
 Returns the effective result by combining `isInterstitialAd` and `forceInterstitialPresentation`
 */
@property (nonatomic, readonly) BOOL presentAsInterstitial;

/**
 Interstitial layout
 */
@property (nonatomic, assign) PBMInterstitialLayout interstitialLayout;

/**
 Size for the ad.
 */
@property (nonatomic, assign) CGSize size;

/**
 Sets a video interstitial ad unit as an opt-in video
 */
@property (nonatomic, assign) BOOL isOptIn;

/**
 Indicates whether the ad is built-in video e.g. 300x250.
 */
@property (nonatomic, assign) BOOL isBuiltInVideo;

/**
 This property indicated winning bid ad format (ext.prebid.type)
 */
@property (nonatomic, strong, nullable) AdFormat *winningBidAdFormat;

/**
 This property indicates the maximum available playback time in seconds.
 */
@property (nonatomic, strong) NSNumber* maxVideoDuration;

/**
 This property indicates whether the ad should run playback with sound or not.
 */
@property (nonatomic, assign) BOOL isMuted;

/**
 This property indicates whether mute controls is visible on the screen.
 */
@property (nonatomic, assign) BOOL isSoundButtonVisible;

/**
 This property indicates the area which the close button should occupy on the screen.
 */
@property (nonatomic, strong) NSNumber* closeButtonArea;

/**
 This property indicates the position of the close button on the screen.
 */
@property (nonatomic, assign) Position closeButtonPosition;

/**
 This property indicates the area which the skip button should occupy on the screen.
 */
@property (nonatomic, strong) NSNumber* skipButtonArea;

/**
 This property indicates the position of the skip button on the screen.
 */
@property (nonatomic, assign) Position skipButtonPosition;

/**
 This property indicates the number of seconds which should be passed from the start of playback until the skip or close button should be shown.
 */
@property (nonatomic, strong) NSNumber* skipDelay;

#pragma mark - Impression Tracking

@property (nonatomic, assign) NSTimeInterval pollFrequency;

@property (nonatomic, assign) NSUInteger viewableArea;

@property (nonatomic, assign) NSTimeInterval viewableDuration;

#pragma mark - Other

/**
 If provided, this block will be called instead of directly attempting to handle clickthrough event.
 */
@property (nonatomic, copy, nullable) PBMCreativeClickHandlerBlock clickHandlerOverride;

@end
NS_ASSUME_NONNULL_END
