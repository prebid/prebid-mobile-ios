//
//  AFPlayerViewControllerPlayback.h
//  AdformAdvertising
//
//  Created by Vladas Drejeris on 09/03/16.
//  Copyright © 2016 adform. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "AFContentPlayback.h"

@interface AFAVPlayerViewControllerPlayback : NSObject <AFContentPlayback>

/**
 The player view controller that is being managed by the content playback object.
 */
@property (nonatomic, strong) AVPlayerViewController *playerViewController;

@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) BOOL mute;

/**
 Designated intializer for AFPlayerViewControllerPlayback.
 
 @param player A player that is managed by the content playback object.
    This parameter cannot be nil.
 */
- (instancetype)initWithPlayer:(AVPlayerViewController *)player;

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
