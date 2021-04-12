//
//  MPInlineAdAdapter+Private.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

#import "MPInlineAdAdapter.h"
#import "MPInlineAdAdapter+MPInlineAdAdapterDelegate.h"

#import "MPAdAdapterDelegate.h"
#import "MPAdConfiguration.h"
#import "MPAdContainerView.h"
#import "MPAdImpressionTimer.h"
#import "MPAnalyticsTracker.h"
#import "MPTimer.h"
#import "MPViewabilityTracker.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPInlineAdAdapter () <MPAdImpressionTimerDelegate>

@property (nonatomic, weak, readwrite) id<MPInlineAdAdapterDelegate> delegate; // default is `self`

@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic) MPAdImpressionTimer *impressionTimer;
@property (nonatomic, strong) MPTimer *timeoutTimer;

@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, weak) id<MPAdAdapterBaseDelegate> adapterDelegate;
@property (nonatomic, copy) NSDictionary *localExtras;
@property (nonatomic, strong) UIView *adView;
@property (nonatomic, strong) id<MPAnalyticsTracker> analyticsTracker;

// Viewability
@property (nonatomic, nullable, strong) id<MPViewabilityTracker> viewabilityTracker;

- (void)didStopLoading;

- (void)startTimeoutTimer;

- (void)startViewableTrackingTimer;

- (void)trackImpression;
- (void)trackClick;

/**
 Creates a Viewability tracker for webview creatives.
 @param webContainer The view that contains a web view in the view hierarchy, in addition to other UI elements that are
 considered friendly obstructions.
 @return A tracker instance if Viewability is initialized, enabled, and the tracker successfully created; otherwise @c nil.
 */
- (id<MPViewabilityTracker> _Nullable)viewabilityTrackerForWebContentInView:(MPAdContainerView *)webContainer;

@end

NS_ASSUME_NONNULL_END
