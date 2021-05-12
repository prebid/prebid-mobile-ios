//
//  MPAdConfiguration.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAdViewConstant.h"
#import "MPGlobal.h"
#import "MPImpressionData.h"
#import "MPSKAdNetworkClickthroughData.h"
#import "MPVideoEvent.h"
#import "MPViewabilityContext.h"

@class MPImageCreativeData;
@class MPReward;
@class MPVASTTrackingEvent;

typedef NS_ENUM(NSUInteger, MPAfterLoadResult) {
    MPAfterLoadResultMissingAdapter,
    MPAfterLoadResultAdLoaded,
    MPAfterLoadResultError,
    MPAfterLoadResultTimeout
};

extern NSString * const kAdTypeMetadataKey;
extern NSString * const kAdUnitWarmingUpMetadataKey;
extern NSString * const kClickthroughMetadataKey;
extern NSString * const kCreativeIdMetadataKey;
extern NSString * const kCustomEventClassNameMetadataKey;
extern NSString * const kCustomEventClassDataMetadataKey;
extern NSString * const kNextUrlMetadataKey;
extern NSString * const kFormatMetadataKey;
extern NSString * const kBeforeLoadUrlMetadataKey;
extern NSString * const kAfterLoadUrlMetadataKey;
extern NSString * const kAfterLoadSuccessUrlMetadataKey;
extern NSString * const kAfterLoadFailureUrlMetadataKey;
extern NSString * const kHeightMetadataKey;
extern NSString * const kImpressionTrackerMetadataKey;
extern NSString * const kImpressionTrackersMetadataKey;
extern NSString * const kNativeSDKParametersMetadataKey;
extern NSString * const kNetworkTypeMetadataKey;
extern NSString * const kRefreshTimeMetadataKey;
extern NSString * const kAdTimeoutMetadataKey;
extern NSString * const kWidthMetadataKey;
extern NSString * const kDspCreativeIdKey;
extern NSString * const kPrecacheRequiredKey;
extern NSString * const kIsVastVideoPlayerKey;
extern NSString * const kRewardedVideoCurrencyNameMetadataKey;
extern NSString * const kRewardedVideoCurrencyAmountMetadataKey;
extern NSString * const kRewardedVideoCompletionUrlMetadataKey;
extern NSString * const kRewardedCurrenciesMetadataKey;
extern NSString * const kRewardedDurationMetadataKey;
extern NSString * const kRewardedPlayableRewardOnClickMetadataKey;
extern NSString * const kImpressionDataMetadataKey;
extern NSString * const kVASTVideoTrackersMetadataKey;

extern NSString * const kFullAdTypeMetadataKey;
extern NSString * const kOrientationTypeMetadataKey;

extern NSString * const kAdTypeHtml;
extern NSString * const kAdTypeInterstitial;
extern NSString * const kAdTypeMraid;
extern NSString * const kAdTypeClear;
extern NSString * const kAdTypeNative;
extern NSString * const kAdTypeRewardedVideo;
extern NSString * const kAdTypeRewardedPlayable;
extern NSString * const kAdTypeVAST;
extern NSString * const kAdTypeFullscreen;

extern NSString * const kClickthroughExperimentBrowserAgent;

extern NSString * const kViewabilityDisableMetadataKey;
extern NSString * const kViewabilityVerificationResourcesKey;

extern NSString * const kBannerImpressionVisableMsMetadataKey;
extern NSString * const kBannerImpressionMinPixelMetadataKey;

@interface MPAdConfiguration : NSObject

@property (nonatomic, readonly) BOOL isFullscreenAd;
@property (nonatomic, assign) BOOL adUnitWarmingUp;
@property (nonatomic, readonly) BOOL isMraidAd;
@property (nonatomic, copy) NSString *adType; // the value is a `kAdType` constant from "x-adtype"
// If this flag is YES, it implies that we've reached the end of the waterfall for the request
// and there is no need to hit ad server again.
@property (nonatomic) BOOL isEndOfWaterfall;
@property (nonatomic, assign) CGSize preferredSize;
@property (nonatomic, strong) NSArray<NSURL *> *clickTrackingURLs;
@property (nonatomic, strong) NSArray<NSURL *> *impressionTrackingURLs;
@property (nonatomic, strong) NSURL *nextURL;
@property (nonatomic, strong) NSArray<NSURL *> *beforeLoadURLs;
@property (nonatomic, assign) NSTimeInterval refreshInterval;
@property (nonatomic, assign) NSTimeInterval adTimeoutInterval;
@property (nonatomic, copy) NSData *adResponseData;
@property (nonatomic, strong) NSDictionary *nativeSDKParameters;
@property (nonatomic, assign) Class adapterClass;
@property (nonatomic, strong) NSDictionary *adapterClassData;
@property (nonatomic, assign) MPInterstitialOrientationType orientationType;
@property (nonatomic, copy) NSString *dspCreativeId;
@property (nonatomic, assign) BOOL precacheRequired;
@property (nonatomic, assign) BOOL isVastVideoPlayer;
@property (nonatomic, strong) NSDate *creationTimestamp;
@property (nonatomic, copy) NSString *creativeId;
@property (nonatomic, copy) NSString *metadataAdType;
@property (nonatomic, assign) CGFloat nativeImpressionMinVisiblePixels;
@property (nonatomic, assign) CGFloat nativeImpressionMinVisiblePercent; // The pixels Metadata takes priority over percentage, but percentage is left for backwards compatibility
@property (nonatomic, assign) NSTimeInterval nativeImpressionMinVisibleTimeInterval;
@property (nonatomic) NSDictionary<MPVideoEvent, NSArray<MPVASTTrackingEvent *> *> *vastVideoTrackers;
@property (nonatomic, readonly) NSArray<MPReward *> *availableRewards;
@property (nonatomic, strong) MPReward *selectedReward;
@property (nonatomic, strong) NSArray<NSString *> *rewardedVideoCompletionUrls;
@property (nonatomic, assign) NSTimeInterval rewardedDuration;
@property (nonatomic, copy) NSString *advancedBidPayload;
@property (nonatomic, strong) MPImpressionData *impressionData;
@property (nonatomic, strong) MPSKAdNetworkClickthroughData *skAdNetworkClickthroughData;
@property (nonatomic, assign) BOOL enableEarlyClickthroughForNonRewardedVideo;
@property (nonatomic, strong) MPImageCreativeData *imageCreativeData; // Will be nil if unable to parse

@property (nonatomic, strong, readonly) MPViewabilityContext *viewabilityContext;

/**
 MRAID `useCustomClose()` functionality is available for use.
 */
@property (nonatomic, readonly) BOOL mraidAllowCustomClose;

/**
 Unified ad unit format in its raw string representation.
 */
@property (nonatomic, copy) NSString *format;

/**
 The ad is capable of rewarding users.
 */
@property (nonatomic, readonly) BOOL isRewarded;

// viewable impression tracking
@property (nonatomic) NSTimeInterval impressionMinVisibleTimeInSec;
@property (nonatomic) CGFloat impressionMinVisiblePixels;

/**
 When there is no actual reward, `availableRewards` contains a default reward with the type
 `kMPRewardCurrencyTypeUnspecified`, thus we cannot simply count the array size of `availableRewards`
 to tell whether there is a valid reward. For historical reason, this default reward exist even for
 non-rewarded ads.

 Note: This indicator is only for ads to be presented by the MoPub SDK, not for 3rd party mediation
 SDK's. This is because ad response might not provide the reward info upfront, but the ad still
 expect to receive reward info eventually from 3rd party mediation SDK when the ad finishes showing.
 As a result, we cannot rely on the presence of the reward info to decide whether an ad expected;
 instead, we should check the ad type for the reward expectation. The name
 @c hasValidRewardFromMoPubSDK implies the reward might come from a 3rd party SDK.
 */
@property (nonatomic, readonly) BOOL hasValidRewardFromMoPubSDK;

- (instancetype)initWithMetadata:(NSDictionary *)metadata data:(NSData *)data isFullscreenAd:(BOOL)isFullscreenAd;

// Default @c init is unavailable
- (instancetype)init NS_UNAVAILABLE;

- (BOOL)hasPreferredSize;
- (MPAdContentType)adContentType;
- (NSString *)adResponseHTMLString;
- (NSArray <NSURL *> *)afterLoadUrlsWithLoadDuration:(NSTimeInterval)duration loadResult:(MPAfterLoadResult)result;

@end
