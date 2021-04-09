//
//  MPAdViewOverlay.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPAdViewConstant.h"
#import "MPVASTIndustryIconView.h"
#import "MPVideoPlayerViewOverlay.h"
#import "MPViewabilityObstruction.h"
#import "MPViewableView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MPAdViewOverlayDelegate
<
MPVASTIndustryIconViewDelegate,
MPVideoPlayerViewOverlayDelegate
>
@end

/**
 This is an overlay of @c MPAdContainerView for full screen VAST ad, which should be added as the
 top-most subview that covers the whole area of the @c MPAdContainerView. Timer related activities
 are affected by app life cycle events.

 See documentation at https://developers.mopub.com/dsps/ad-formats/video/

 Note: Industry icon placing logic is different from the VAST spec per MoPub video format
 documentation: "We will ignore x/y coordinates for the icon and will always place it in the top
 left corner to ensure a consistent user experience."
 */
@interface MPAdViewOverlay : MPViewableView <MPViewabilityObstruction>

@property (nonatomic, readonly) BOOL wasTapped;
@property (nonatomic, weak) id<MPAdViewOverlayDelegate> delegate;

/**
 Provided the ad size and Close button location, returns the frame of the Close button.
 Note: The provided ad size is assumed to be at least 50x50 (@c kMPAdViewCloseButtonSize), otherwise
 the return value is undefined.

 @param adSize The size of the ad.
 @param location The location of the close button.
 */
+ (CGRect)closeButtonFrameForAdSize:(CGSize)adSize atLocation:(MPAdViewCloseButtonLocation)location;

/**
 Set the Close button location with UI update. Only MRAID ads care, and all other ads default to top-right.
 */
- (void)setCloseButtonLocation:(MPAdViewCloseButtonLocation)closeButtonLocation;

/**
 Set the Close button location with UI update.
 */
- (void)setCloseButtonType:(MPAdViewCloseButtonType)closeButtonType;

@end

#pragma mark -

@interface MPAdViewOverlay (MPVideoPlayerViewOverlay) <MPVideoPlayerViewOverlay>
@end

NS_ASSUME_NONNULL_END
