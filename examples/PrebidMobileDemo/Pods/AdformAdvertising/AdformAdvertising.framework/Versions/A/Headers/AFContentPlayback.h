//
//  AFContentPlayback.h
//  AdformAdvertising
//
//  Created by Vladas Drejeris on 13/04/15.
//  Copyright (c) 2015 adform. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This notification must be posted by an object implementing AFContentPlayback protocol
 when content video player starts video playback.
 If video player changes the content it is playing (a new video file is loaded) 
 this notifications should be posted again when video playback of the new content starts.
 */
static NSString *const kAFContentPlaybackStartedNotificaiton = @"kAFContentPlaybackStartedNotification";

/**
 This notification must be posted by an object implementing AFContentPlayback protocol
 when content video player finishes video playback.
 If video player changes the content it is playing (a new video file is loaded)
 this notifications should be posted again when video playback of the new content finishes.
 */
static NSString *const kAFContentPlaybackFinishedNotificaiton = @"kAFContentPlaybackFinishedNotification";

/**
 This protocol defines the video player behaviour required to play ads.
 
 You must also send kAFContentPlaybackStartedNotificaiton when video player starts playing
 and kAFContentPlaybackFinishedNotificaiton when video player finishes playing content.
 These notifications must be fired only once per video file.
 They are required properly show pre-roll and post-roll ads.
 */
@protocol AFContentPlayback <NSObject>

@required
/**
 Duration of the media file.
 */
@property (nonatomic, assign, readonly) NSTimeInterval duration;
/**
 Current time of the video playback.
 
 This property must be KVO.
 */
@property (nonatomic, assign, readonly) NSTimeInterval currentTime; // Must be KVO
/**
 Identifies if video player is muted.
 */
@property (nonatomic, assign, readonly) BOOL mute;
/**
 Indicates if video player is in fullscreen mode.
 */
@property (nonatomic, assign, readonly) BOOL fullscreen;

/**
 Enables or disables full screen mode.
 
 @param fullscreen Indicates if fullscreen mode should be enabled or disabled.
 @param animated Indicates if transition should be animated.
 */
- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL )animated;

/**
 Starts or resumes video playback.
 */
- (void)play;

/**
 Pauses video playback.
 */
- (void)pause;

/**
 Identifies that video player only shows video in fullscreen mode.
 
 Return true if you are using view controller that can only be displayed in fullscreen mode, e.g. AVPlayerViewController.
 Otherwise return false.
 */
- (BOOL)isFullscreenOnly;

@end
