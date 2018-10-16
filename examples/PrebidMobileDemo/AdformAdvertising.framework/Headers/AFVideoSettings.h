//
//  AFVideoSettings.h
//  AdformAdvertising
//
//  Created by Vladas Drejeris on 22/06/15.
//  Copyright (c) 2015 Adform. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Video player controls styles.
 */
typedef NS_ENUM(NSInteger, AFVideoPlayerControlsStyle) {
    /// Player uses controls with a bar, bar is translucent if posible.
    AFVideoPlayerControlsStyleDefault,
    /// Player uses controls without a bar, they are placed directly on top of the video.
    AFVideoPlayerControlsStyleMinimal
};

/**
 Video ad close button behavior.
 
 Defines when close button should be shown.
 */
typedef NS_ENUM(NSInteger, AFVideoAdCloseButtonBehavior) {
    /// The ad doesn't have a close button.
    AFVideoAdCloseButtonBehaviorNoButton,
    /// The close button appears when the ad has finished playback.
    AFVideoAdCloseButtonBehaviorWhenFinished,
    /// The close button is visible all the time.
    AFVideoAdCloseButtonBehaviorAllways
};

/**
 Video settings object allows you to configure video ads. 
 You can choose close button behiavior, set initial mute and enable auto close function.
 */
@interface AFVideoSettings : NSObject <NSCopying>

/**
 Use this property to control the clsoe ad button behiaviour. You can show no close button - AFVideoCloseButtonTypeNoButton,
 display the button only when ad has finished playing the video - AFVideoCloseButtonTypeWhenFinished,
 or allways show the close button - AFVideoCloseButtonTypeAllways.
 
 Default value - AFVideoCloseButtonTypeNoButton
 
 @see AFVideoAdCloseButtonType
 */
@property (nonatomic, assign) AFVideoAdCloseButtonBehavior closeButtonBehavior;

/**
 This property defines if video should start playing muted. If this property is set to TRUE,
 then after the loading, video will start playing muted.
 
 Default value - TRUE
 */
@property (nonatomic, assign, getter=isInitialyMuted) BOOL initialyMuted;

/**
 This property identifies if video ad should be close automatically when the video playback finishes.
 
 Default value - FALSE
 */
@property (nonatomic, assign) BOOL autoClose;

/**
 This property specifies what visual style video player should use for its controls. You can choose from default and minimal style.
 
 Default value - AFVideoPlayerControlsStyleDefault
 
 @see AFVideoPlayerControlsStyle
 */
@property (nonatomic, assign) AFVideoPlayerControlsStyle controlsStyle;

/**
 Setting this property will enable fallback for video ads.

 If a valid master tag id is set to this property 
 then after failing to load a video banner the ad view will try to load an HTML banner 
 using the provided master tag to fill the placement.
 */
@property (nonatomic, assign) NSInteger fallbackMasterTagId;

/**
 Defines if video ad should be initially displayed fullscreen.
 
 Default value - FALSE
 */
@property (nonatomic, assign) BOOL fullscreen;

@end
