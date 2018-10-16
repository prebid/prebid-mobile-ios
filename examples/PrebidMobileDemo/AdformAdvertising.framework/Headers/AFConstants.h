//
//  AFConstants.h
//  AdformAdvertising
//
//  Created by Vladas Drejeris on 25/02/15.
//  Copyright (c) 2015 Adform. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Ad view animation duration, use it to match content animation with ad view animations.
 */
extern CGFloat const AFAdViewAnimationDuration;

/**
 Default ad size for iPhone - 320x50.
 */
extern CGSize const AFDefaultIphoneAdSize;

/**
 Default ad size for iPad - 728x90.
 */
extern CGSize const AFDefaultIpadAdSize;

/**
 The size for a smart ad placement.
 */
extern CGSize const AFSmartAdSize;


/**
 Defines the types of web views, that can be used by the SDK to load HTML banners.
 */
typedef NS_ENUM (NSInteger, AFWebViewType) {
    /// Identifies that the SDK should use UIWebView to load HTML banners.
    AFUIWebView,
    
    /// Identifies that the SDK should use WKWebView to load HTML banners.
    /// This type is availbe obly on iOS 8+.
    AFWKWebView NS_ENUM_AVAILABLE_IOS(8_0)
};

/**
 Ad view state values.
 */
typedef NS_ENUM (NSInteger, AFAdState) {
    /// Ad view is visible and showing an ad.
    AFAdStateVisible,
    
    /// Ad view is hidden and no ad is being shown.
    AFAdStateHidden,
    
    /// Ad view is being displayed.
    AFAdStateInShowTransition,
    
    /// Ad view is being hidden.
    AFAdStateInHideTransition
};

/**
 Ad view position.
 */
typedef NS_ENUM (NSInteger, AFAdPosition) {
    /// Ad view is positioned at the top of superview, centered.
    AFAdPositionTop,
    
    /// Ad view is positioned at the bottom of superview, centered.
    AFAdPositionBottom,
    
    /// Default ad view position - AFAdPositionBottom.
    AFAdPositionDefault
};

/**
 Ad transition animation style values.
*/
typedef NS_ENUM (NSInteger, AFAdTransitionStyle) {
    /// New ads slide up.
    AFAdTransitionStyleSlide,
    
    /// New ads fade in.
    AFAdTransitionStyleFade,
    
    /// Ad transition is not animated.
    AFAdTransitionStyleNone
};

/**
 Modal view presentation animation style values.
 */
typedef NS_ENUM (NSInteger, AFModalPresentationStyle) {
    /// When the modal view is presented, it slides up from the bottom of the screen.
    AFModalPresentationStyleSlide,
    
    /// When the modal view is presented, it fades in.
    AFModalPresentationStyleFadeInOut,
    
    /// Presentation is not animated.
    AFModalPresentationStyleNone
};

/// Adform Advertising SDK error domain.
extern NSString *const kAFErrorDomain;

/**
 Error codes.
*/
typedef NS_ENUM(NSInteger, AFErrorCode) {
    /// A network error occurred while loading ads from server.
    AFNetworkError = 0,
    
    /// The request has timed out.
    AFTimedOutError = 1,
    
    /// An ad server error occurred.
    AFServerError = 2,
    
    /// An internal SDK error occurred.
    AFInternalError = 3,
    
    /// The ad server returned invalid response.
    AFInvalidServerResponseError = 4,
    
    /// The ad server returned valid response, but there was no ad to show.
    AFNoAdToShowError = 5,
    
    /// The sdk was unable to handle a VAST xml retreived from the ad server.
    AFInvalidVASTResponseError = 6
};


/**
 Video player controls mask.
 
 Defines which controlls should be visible when playing content media.
 */
typedef NS_OPTIONS(NSInteger, AFVideoPlayerControlsMask) {
    /// All controls are hidden.
    AFVideoPlayerControlsMaskNone = 0,
    /// Play/pause button is visible.
    AFVideoPlayerControlsMaskPlayPause = (1 << 0),
    /// Elapsed time label is visible.
    AFVideoPlayerControlsMaskCurrentTime = (1 << 1),
    /// Time scrubber is visible.
    AFVideoPlayerControlsMaskScrubber = (1 << 2),
    /// Time remaining label is visible. Time remaining is displayed as negative value.
    AFVideoPlayerControlsMaskTimeRemaining = (1 << 3),
    /// Mute button is visible.
    AFVideoPlayerControlsMaskMute = (1 << 4),
    /// Fullscreen button is visible.
    AFVideoPlayerControlsMaskFullScreen = (1 << 5),
    /// Video count view is visible.
    AFVideoPlayerControlsMaskVideoCount = (1 << 6),
    /// All controls are visible.
    AFVideoPlayerControlsMaskAll = (AFVideoPlayerControlsMaskPlayPause | AFVideoPlayerControlsMaskCurrentTime | AFVideoPlayerControlsMaskScrubber | AFVideoPlayerControlsMaskTimeRemaining | AFVideoPlayerControlsMaskMute | AFVideoPlayerControlsMaskFullScreen | AFVideoPlayerControlsMaskVideoCount),
    /// Controls for ads.
    AFVideoPlayerControlsMaskAds = (AFVideoPlayerControlsMaskPlayPause | AFVideoPlayerControlsMaskScrubber | AFVideoPlayerControlsMaskTimeRemaining | AFVideoPlayerControlsMaskMute | AFVideoPlayerControlsMaskFullScreen | AFVideoPlayerControlsMaskVideoCount),
    /// Controls for ads without fullscreen.
    AFVideoPlayerControlsMaskAdsNoFullscreen = (AFVideoPlayerControlsMaskPlayPause | AFVideoPlayerControlsMaskScrubber | AFVideoPlayerControlsMaskTimeRemaining | AFVideoPlayerControlsMaskMute | AFVideoPlayerControlsMaskVideoCount)
};

/**
 Banner loading behaviour.

 Defines how SDK should load banners.
 */
typedef NS_ENUM(NSInteger, AFBannerLoadingBehaviour) {

    /// SDK doesn't wait for any JS event indicating that banner has finished loading
    /// and decides based on web view delegate callback.
    AFBannerLoadingBehaviourInstant = 0,

    /// SDK waits for 'load' JS event to detect the end of banner loading.
    AFBannerLoadingBehaviourWaitForLoadEvent = 1,

    /// SDK waits for 'DOMContentLoaded' JS event to detect the end of banner loading.
    AFBannerLoadingBehaviourWaitForDOMContentLoadedEvent = 2,

    /// SDK waits for 'pageshow' JS event to detect the end of banner loading.
    AFBannerLoadingBehaviourWaitForPageshowEvent = 3
};
