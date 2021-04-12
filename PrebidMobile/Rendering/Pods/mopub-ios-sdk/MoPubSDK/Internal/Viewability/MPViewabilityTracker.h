//
//  MPViewabilityTracker.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPVideoEvent.h"
#import "MPViewabilityObstruction.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MPViewabilityTracker
/**
 A Boolean value that indicates whether the Viewability tracking is in progress.
 */
@property (nonatomic, readonly) BOOL isTracking;

/**
 Adds friendly obstructions to the tracker. This is typically done when the UI dynamically adds new
 elements on screen such as the Industry Icon and Skip Button.
 @param obstructions Array of friendly obstructions to register with the Viewability tracker.
 */
- (void)addFriendlyObstructions:(NSSet<UIView<MPViewabilityObstruction> *> * _Nullable)obstructions;

/**
 Starts the tracking session.
 For WebView-based creatives, this should be called once the WebView has completed loading the creative.
 For VAST and native ads, this should be called once the creative is shown or added to the view hierarchy.
 @note This method may only be invoked once. Subsequent calls will do nothing.
 */
- (void)startTracking;

/**
 Stops the tracking session. Typically this will be invoked once the ad is no longer in the view hierarchy.
 */
- (void)stopTracking;

/**
Tracks the ad loaded event. This method may only be invoked once.
*/
- (void)trackAdLoaded;

/**
 Tracks the impression event. This method may only be invoked once.
 */
- (void)trackImpression;

/**
 Tracks the specified VAST video event.
 @param event VAST video event to track.
 */
- (void)trackVideoEvent:(MPVideoEvent)event;

/**
 Updates the view that is tracked by the session due to fullscreen expansion, collapsing from fullscreen, or
 for some similar reason.
 @param view The new view to track.
 */
- (void)updateTrackedView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
