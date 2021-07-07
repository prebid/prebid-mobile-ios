//
//  MPFullscreenAdAdapter+Private.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdAdapterDelegate.h"
#import "MPAdContainerView.h"
#import "MPAdEvent.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPAdTargeting.h"
#import "MPAnalyticsTracker.h"
#import "MPCountdownTimerDelegate.h"
#import "MPDiskLRUCache.h"
#import "MPFullscreenAdAdapter.h"
#import "MPFullscreenAdAdapterDelegate.h"
#import "MPFullscreenAdViewController+Web.h"
#import "MPImageLoader.h"
#import "MPVASTTracking.h"
#import "MPVideoConfig.h"
#import "MPViewabilityTracker.h"
#import "MPWebView.h"

// Forward declarations of Swift objects required since it is not
// possible to import MoPub-Swift.h from header files.
@class MPImageCreativeView;
@class MPResumableTimer;

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdAdapter ()

#pragma mark - Common Properties

@property (nonatomic, assign) MPAdContentType adContentType;
@property (nonatomic, strong) MPAdTargeting *targeting;
@property (nonatomic, strong) MPResumableTimer *timeoutTimer;
@property (nonatomic, assign, readwrite) BOOL hasAdAvailable;
@property (nonatomic, strong) id<MPAdDestinationDisplayAgent> adDestinationDisplayAgent; // Note: only used for video and static image

// Once an ad successfully loads, we want to block sending more successful load events.
@property (nonatomic, assign) BOOL hasSuccessfullyLoaded;

// Since we only notify the application of one success per load, we also only notify the application
// of one expiration per success.
@property (nonatomic, assign) BOOL hasExpired;

@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;
@property (nonatomic, assign) BOOL isUserRewarded;

@property (nonatomic, strong) MPFullscreenAdViewController * _Nullable viewController; // set to nil after dismissal

// Viewability
@property (nonatomic, nullable, strong) id<MPViewabilityTracker> viewabilityTracker;

#pragma mark - (MPAdAdapter) Properties

@property (nonatomic, strong) NSString *adUnitId;
@property (nonatomic, copy) NSString *customData;
@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic, weak) id<MPAdAdapterFullscreenEventDelegate, MPAdAdapterRewardEventDelegate> adapterDelegate;
@property (nonatomic, strong) id<MPAnalyticsTracker> analyticsTracker;

#pragma mark - (MPFullscreenAdAdapterDelegate) Properties

@property (nonatomic, weak, readwrite) id<MPFullscreenAdAdapterDelegate> delegate; // default to `self` in `init`
@property (nonatomic, copy) NSDictionary *localExtras;

#pragma mark - Video Properties

@property (nonatomic, strong) id<MPVASTTracking> vastTracking;
@property (nonatomic, strong) id<MPMediaFileCache> mediaFileCache;
@property (nonatomic, strong) MPVASTMediaFile *remoteMediaFileToPlay;
@property (nonatomic, strong) MPVideoConfig *videoConfig;

#pragma mark - Image Properties

@property (nonatomic, strong) MPImageLoader *imageLoader;
@property (nonatomic, strong) MPImageCreativeView *imageCreativeView;

#pragma mark - Methods

/**
 This should be called right after `init` for once and only once.
 */
- (void)setUpWithAdConfiguration:(MPAdConfiguration *)adConfiguration localExtras:(NSDictionary *)localExtras;

- (void)startTimeoutTimer;

- (void)didLoadAd;

- (void)didStopLoadingAd;

- (void)handleAdEvent:(MPFullscreenAdEvent)event;

/**
 The original URLs come from the value of "x-rewarded-video-completion-url" in ad response.
 */
- (NSArray<NSURL *> * _Nullable)rewardedVideoCompletionUrlsByAppendingClientParams;

/**
 Tracks an impression when called the first time. Any subsequent calls will do nothing.
 */
- (void)trackClick;

/**
 Tracks a click when called the first time. Any subsequent calls will do nothing.
 */
- (void)trackImpression;

/**
 Creates a Viewability tracker for webview creatives.
 @param webContainer The view that contains a web view in the view hierarchy, in addition to other UI elements that are
 considered friendly obstructions.
 @return A tracker instance if Viewability is initialized, enabled, and the tracker successfully created; otherwise @c nil.
 */
- (id<MPViewabilityTracker> _Nullable)viewabilityTrackerForWebContentInView:(MPAdContainerView *)webContainer;

/**
 Creates a Viewability tracker for VAST video creatives.
 @param config The video configuration for the VAST creative.
 @param container The view that contains the VAST video player in the view hierarchy, in addition to other UI elements that are
 considered friendly obstructions.
 @param adConfiguration Ad configuration associated with the video configuration.
 @return A tracker instance if Viewability is initialized, enabled, and the tracker successfully created; otherwise @c nil.
*/
- (id<MPViewabilityTracker> _Nullable)viewabilityTrackerForVideoConfig:(MPVideoConfig *)config
                                              containedInContainerView:(MPAdContainerView *)container
                                                       adConfiguration:(MPAdConfiguration *)adConfiguration;

@end

#pragma mark -

@interface MPFullscreenAdAdapter (MPCountdownTimerDelegate) <MPCountdownTimerDelegate>
@end

NS_ASSUME_NONNULL_END
