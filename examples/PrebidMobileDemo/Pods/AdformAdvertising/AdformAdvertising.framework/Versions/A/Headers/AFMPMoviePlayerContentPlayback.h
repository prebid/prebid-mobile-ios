//
//  AFMoviePlayerContentPlayback.h
//  AdformAdvertising
//
//  Created by Vladas Drejeris on 23/04/15.
//  Copyright (c) 2015 adform. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AFContentPlayback.h"

@interface AFMPMoviePlayerContentPlayback : NSObject <AFContentPlayback>

/**
 The movie player that is being managed by the content playback object.
 */
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;

@property (nonatomic, assign, readonly) BOOL mute;


/**
 Designated intializer for AFMoviePlayerContentPlayback.
 
 @param moviePlayer A movie player that is managed by the content playback object. 
    This parameter cannot be nil.
 */
- (instancetype)initWithMoviePlayer:(MPMoviePlayerController *)moviePlayer;

- (void)play;
- (void)pause;

/**
 Resets pre-roll and mid-roll ads.
 
 You should call this method when content of the video player has changed
 to indicate that pre-roll and post-roll ads should be shown again at the
 begining and end of video playback.
 */
- (void)resetAds;

@end
