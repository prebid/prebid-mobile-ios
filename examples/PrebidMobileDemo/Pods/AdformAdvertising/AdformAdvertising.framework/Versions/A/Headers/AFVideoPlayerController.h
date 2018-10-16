//
//  AFVideoPlayerController.h
//  AdformAdvertising
//
//  Created by Vladas Drejeris on 09/04/15.
//  Copyright (c) 2015 adform. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <SafariServices/SafariServices.h>

#import "AFVideoSettings.h"
#import "AFContentPlayback.h"
#import "AFBrowserViewController.h"

/**
 Video player types.
 
 Defines if video player uses external media player for content playback.
 */
typedef NS_ENUM(NSInteger, AFVideoPlayerType) {
    /// Video player plays content media itself.
    AFVideoPlayerInternalContent,
    /// Video player uses external media player for content playback.
    AFVideoPlayerExternalContent
};

/**
 Video player item source types.
 */
typedef NS_ENUM(NSInteger, AFVideoSourceType) {
    /// Source type unknown.
    AFVideoSourceTypeUnknown,
    /// Source type progressive downoalod.
    AFVideoSourceTypeFile,
    /// Source type media streaming.
    AFVideoSourceTypeStreaming
};

/**
 Video scaling modes.
 
 Defines how video is resized inside the player view.
 */
typedef NS_ENUM(NSInteger, AFVideoScalingMode) {
    /// Video is scaled to fill whole player view regardless of the video aspect ration.
    AFVideoScalingModeResize,
    /// Video is scaled to fit in the player view maintaining the video aspect ration.
    AFVideoScalingModeAspectFit,
    /// Video is scaled to fill whole player view maintaining the video aspect ration.
    AFVideoScalingModeAspectFill
};

/**
 Video player playback states.
 */
typedef NS_ENUM(NSInteger, AFVideoPlaybackState) {
    AFVideoPlaybackStateStopped,
    AFVideoPlaybackStatePlaying,
    AFVideoPlaybackStatePaused,
    AFVideoPlaybackStateInterrupted,
    AFVideoPlaybackStateSeekingForward,
    AFVideoPlaybackStateSeekingBackward,
    AFVideoPlaybackStatePlayingAd
};

@protocol AFVideoPlayerDelegate;

/**
 The AFVideoPlayerController class provides a media player that is capable of displaying video advertisements alongside content media.
 */
@interface AFVideoPlayerController : NSObject <AFContentPlayback>

/**
 Defines player type.
 
 Video player can use internal or external media player for content playback.
 
 @see AFVideoPlayerType
 */
@property (nonatomic, assign, readonly) AFVideoPlayerType playerType;

/**
 Determines video player playerControlsView style.
 
 @see AFVideoPlayerControlsStyle
 */
@property (nonatomic, assign) AFVideoPlayerControlsStyle controlsStyle;

/**
 Determines visible video player controls.
 
 @see AFVideoPlayerControlsMask
 */
@property (nonatomic, assign) AFVideoPlayerControlsMask controlsMask;

/**
 Determines video player media content scaling mode.
 
 @see AFVideoScalingMode
 */
@property (nonatomic, assign) AFVideoScalingMode scalingMode;

/**
 Video player view used to display media content.
 */
@property (nonatomic, strong, readonly) UIView *view;

/**
 The object implementing AFVideoPlayerDelegate protocol, which is notified about the video player state changes.
 */
@property (nonatomic, weak) id <AFVideoPlayerDelegate> delegate;


/**
 URL used to load media content.
 */
@property (nonatomic, strong) NSURL *contentURL;

/**
 Currently loaded AVAsset.
 */
@property (nonatomic, strong, readonly) AVAsset *currentAsset;

/**
 Currently loaded AVAsset source type.
 
 @see AFVideoSourceType
 */
@property (nonatomic, assign, readonly) AFVideoSourceType sourceType;

/**
 Indicates the natural dimensions of the media data.
 */
@property (nonatomic, assign, readonly) CGSize videoSize;

/**
 Indicates current media asset duration.
 */
@property (nonatomic, assign, readonly) NSTimeInterval duration;


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
 Indicates elapsed time.
 */
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;

/**
 Indicates content media playback state.
 
 @see AFVideoPlaybackState
 */
@property (nonatomic, assign, readonly) AFVideoPlaybackState playbackState;

/**
 Indicates if video player is playing.
 */
@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;

/**
 Mutes/unmutes the video player.
 
 Same as setting volume to 0/1.0.
 */
@property (nonatomic, assign) BOOL mute;

/** 
 Allows to control video player volume level.
 */
@property (nonatomic, assign) float volume;

/**
 Defines if player should begin playing automatically after the asset was loaded.
 Default value - false.
 */
@property (nonatomic, assign, getter=shouldAutoplay) BOOL autoplay;

/**
 Prepares the current asset for playback.
 */
- (void)prepareToPlay;

/**
 Begins playback of the content video.
 
 If video asset is not loaded when this method is called then it is first loaded and then started.
 In that case 'autoPlay' property of player view will be set to true.
 
 If video is paused calling this method will resume playback.
 */
- (void)play;

/**
 Pauses the video playback.
 
 You can resume the video playback from the same time position by calling 'play' method.
 */
- (void)pause;

/**
 Stops video playback.
 
 Unlike the 'pause' method, this one stops video playback and seeks the video back to 0 time position.
 */
- (void)stop;

/**
 Initializes a new instance of the AFVideoPlayerController.
 
 @param url URL used to load media content.
 
 @return A newly initialized AFVideoPlayerController.
 */
- (instancetype)initWithURL:(NSURL *)url;

@end

/**
 Describes external media player usage.
 */
@interface AFVideoPlayerController (ExternalContentVideo)

/**
 Container view which displays content media.
 
 This container is used to display video ads. Typically you should set a view
 which is used to render video content here, or a superview (container) containing 
 the view used for rendering and player controls.
 
 AFVideoPlayerController ads a subview which is used to display video ads to the container view.
 */
@property (nonatomic, strong, readonly) UIView *container;

/**
 An object implementing 'AFContentPlayback' protocol used to provide information to the AFVideoPlayerController and control
 the content playback.
 */
@property (nonatomic, strong, readonly) id <AFContentPlayback> contentPlayback;

/**
 Initializes a new instance of the AFVideoPlayerController with external content player.
 
 @param container A view with external content player. Cannot be nil.
 @param contentPlayback An object conforming to 'AFContentPlayback' protocol used to control Cannot be nil.
 
 @return A newly initialized AFVideoPlayerController.
 */
- (instancetype)initWithContainer:(UIView *)container andContentPlayback:(id <AFContentPlayback>)contentPlayback;

@end

@class AFCuePoint;

/**
 Describes advertisement controls.
 */
@interface AFVideoPlayerController (Ads)

/**
 An integer representing Adform master tag id used to load pre-roll ads.
 */
@property (nonatomic, assign) NSInteger preRollMId;

/**
 An integer representing Adform master tag id used to load mid-roll ads.
 */
@property (nonatomic, assign) NSInteger midRollMId;

/**
 An integer representing Adform master tag id used to load post-roll ads.
 */
@property (nonatomic, assign) NSInteger postRollMId;

/**
 An array of cue points, that define places in content video, where ads may be played.
 Cue points are cleared automatically when content url changes.
 */
@property (nonatomic, strong, readonly) NSArray<AFCuePoint *> *cuePoints;

/**
 Loads all ads in advance.
 
 Use this method if you want to load all the ads in advance.
 Otherwise, the sdk tracks the playback time of the content video and
 request the ads at certain times just before they should be displayed to the user.
 
 You must call this method after setting the master tag ids.
 */
- (void)preloadAds;

/**
 Registers an array of cue points.
 
 This method does't override previously added cue points.
 
 @param cuePoints An array of cue points to register.
 */
- (void)registerCuePoints:(NSArray<AFCuePoint*> *)cuePoints;

/**
 Unregisters an array of cue points previously registered to the player.
 
 @param cuePoints An array of cue points to unregister.
 */
- (void)unregisterCuePoints:(NSArray<AFCuePoint*> *)cuePoints;

@end


/**
 Video seeking and fast forward/reverse controls.
 */
@interface AFVideoPlayerController (Seeking)

/**
 Begins playing fast forward.
 */
- (void)beginSeekingForward;

/**
 Begins playing fast reverse.
 */
- (void)beginSeekingBackward;

/**
 Stops playing fast forward/reverse.
 */
- (void)endSeeking;

/**
 Seeks video to time position.
 
 @param time NSTimeInterval value indicating seeking position.
 @param completionHandler A block of code called when seeking has finished.
 */
- (void)seekToTime:(NSTimeInterval )time completionHandler:(void (^)(BOOL finished))completionHandler;

@end


/**
 External playback
 */
@interface AFVideoPlayerController (ExternalPlaybackSupport)

/**
 Indicates whether the player can switch to external "playback mode".
 */
@property (nonatomic, assign) BOOL allowsExternalPlayback;

@end


/**
 Logs
 */
@interface AFVideoPlayerController (Logs)

/**
 Acces log from internal AVPlayer.
 */
@property (nonatomic, strong, readonly) AVPlayerItemAccessLog *accessLog;

/**
 Error log from internal AVPlayer.
 */
@property (nonatomic, strong, readonly) AVPlayerItemErrorLog *errorLog; 

@end


/**
 The delegate of an AFVideoPlayerController object must adopt the AFVideoPlayerDelegate protocol.
 
 This protocol has optional methods which allow the delegate to be notified of video player state changes.
 If video player is used in external mode, then only methods about ad loading and display will be called.
 */
@protocol AFVideoPlayerDelegate <NSObject>

@optional
/**
 Gets called when an AFVideoPlayerController successfully loads an ad.
 
 @param videoPlayer A video player object calling the method.
 */
- (void)videoPlayerFinishedLoadingAd:(AFVideoPlayerController *)videoPlayer; 

/**
 Gets called when an AFVideoPlayerController fails to load an ad.
 
 @param videoPlayer A video player object calling the method.
 @param error An error indicating what went wrong.
 */
- (void)videoPlayer:(AFVideoPlayerController *)videoPlayer failedLoadingAdWithError:(NSError *)error;

/**
 Gets called when an AFVideoPlayerController is going to begin playing ads.
 
 @param videoPlayer A video player object calling the method.
 */
- (void)videoPlayerWillBeginPlayingAds:(AFVideoPlayerController *)videoPlayer;

/**
 Gets called when an AFVideoPlayerController has ended playing the ads.
 
 @param videoPlayer A video player object calling the method.
 */
- (void)videoPlayerDidEndPlayingAds:(AFVideoPlayerController *)videoPlayer;

/**
 Asks the delegate object if video player should show pre-roll ad.
 
 If you return false pre-roll ad will not be displayed.
 If you don't implement this method pre-roll ad is displayed by default.
 
 @param videoPlayer A video player object calling the method.
 
 @return True if ad should be shown, otherwise false.
 */
- (BOOL)shouldVideoPlayerShowPreRollAd:(AFVideoPlayerController *)videoPlayer;

/**
 Asks the delegate object if video player should show mid-roll ad at specified time.
 
 If you return false mid-roll ad will not be displayed.
 If you don't implement this method mid-roll ads will be displayed by default.
 
 @param videoPlayer A video player object calling the method.
 @param time A time at which the ad should be displayed.
 
 @return True if ad should be shown, otherwise false.
 */
- (BOOL)shouldVideoPlayer:(AFVideoPlayerController *)videoPlayer showMidRollAdAtTime:(NSTimeInterval )time;

/**
 Asks the delegate object if video player should show post-roll ad.
 
 If you return false post-roll ad will not be displayed.
 If you don't implement this method post-roll ad is displayed by default.
 
 @param videoPlayer A video player object calling the method.
 
 @return True if ad should be shown, otherwise false.
 */
- (BOOL)shouldVideoPlayerShowPostRollAd:(AFVideoPlayerController *)videoPlayer;

/**
 Gets called when an AFVideoPlayerController has started video playback.
 
 @param videoPlayer A video player object calling the method.
 */
- (void)videoPlayerStartedPlaying:(AFVideoPlayerController *)videoPlayer;

/**
 Gets called when an AFVideoPlayerController has finished playing video.
 
 @param videoPlayer A video player object calling the method.
 */
- (void)videoPlayerFinishedPlaying:(AFVideoPlayerController *)videoPlayer;

/**
 Gets called when an AFVideoPlayerController has been paused.
 
 @param videoPlayer A video player object calling the method.
 */
- (void)videoPlayerPaused:(AFVideoPlayerController *)videoPlayer;

/**
 Gets called when an AFVideoPlayerController has been interrupted, i.e. player wasn't able to keep up buffering the video.
 
 @param videoPlayer A video player object calling the method.
 */
- (void)videoPlayerInterrupted:(AFVideoPlayerController *)videoPlayer;

/**
 Gets called when an AFVideoPlayerController has resumed after being paused or interrupted.
 
 @param videoPlayer A video player object calling the method.
 */
- (void)videoPlayerResumed:(AFVideoPlayerController *)videoPlayer;

/**
 Gets called when ad view is presenting an internal browser to allow customization.

 @param videoPlayer A video player object calling the method.
 @param browserViewController A browser view controller that will be presented.
*/
- (void)videoPlayer:(AFVideoPlayerController *)videoPlayer willOpenInternalBrowser:(AFBrowserViewController *)browserViewController;

/**
 Gets called when ad view is presenting a safari view controller to allow customization.

 @param videoPlayer A video player object calling the method.
 @param safariViewController A safari view controller that is being presented.
*/
- (void)videoPlayer:(AFVideoPlayerController *)videoPlayer willOpenSafariViewController:(SFSafariViewController *)safariViewController;

@end
