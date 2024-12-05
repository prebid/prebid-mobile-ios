/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "PBMCreativeModel.h"
#import "PBMError.h"
#import "PBMFunctions+Private.h"
#import "PBMMacros.h"
#import "PBMModalManager.h"
#import "PBMModalState.h"
#import "PBMOpenMeasurementSession.h"
#import "PBMTouchDownRecognizer.h"
#import "PBMVideoCreative.h"
#import "PBMVideoView.h"
#import "UIView+PBMExtensions.h"

#import "PrebidMobileSwiftHeaders.h"
#if __has_include("PrebidMobile-Swift.h")
#import "PrebidMobile-Swift.h"
#else
#import <PrebidMobile/PrebidMobile-Swift.h>
#endif

static NSString * const PBMAVPlayerObserverKeyStatus        = @"status";
static NSString * const PBMAVPlayerObserverKeyVolume        = @"volume";
static NSString * const PBMAudioSessionObserverKeyVoulume   = @"outputVolume";

static NSString * const PBMLearnMoreButtonTitle             = @"Learn More";
static NSString * const PBMWatchAgainButtonTitle            = @"Watch Again";

static BOOL const ENABLE_OUTSTREAM_TAP_TO_EXPAND = NO;
static CGSize const MUTE_BUTTON_SIZE = { 24, 24 };

#pragma mark - Private Extension

@interface PBMVideoView () <UIGestureRecognizerDelegate>

#pragma mark Model

@property (nonatomic, weak) PBMVideoCreative *creative;
@property (nonatomic, strong) PBMEventManager *eventManager;
@property (nonatomic, strong) PBMTouchDownRecognizer *tapdownGestureRecognizer;

#pragma mark UI

@property (nonatomic, strong) UIButton *btnLearnMore;
@property (nonatomic, strong) UIButton *btnWatchAgain;

@property (nonatomic, weak) UIButton *btnMute;
@property (nonatomic, weak) UIButton *btnUnmute;
@property (nonatomic, weak) UIView *muteControlsView;

@property (nonatomic, strong) PBMAdViewButtonDecorator *skipButtonDecorator;

#pragma mark Injected Properties

@property (nonatomic, strong) NSData *preloadedData;

#pragma mark Runtime Properties

@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) CGFloat previousCompletetionPercentage;

@property (atomic, strong) NSNumber *isInitialVolumeTracked;

// Optimization: since we show only preloaded data we can free the buffer when data is sent to the player.
// This property holds the amount of data that was sent to the player.
@property (atomic, assign) NSInteger requestedDataLength;

@property (nonatomic, assign) BOOL isPlaybackStarted;
@property (nonatomic, assign) BOOL isPlaybackFinished;

@property (nonatomic, strong, nonnull) NSNumber * progressBarDuration;

- (NSNumber *)calculateProgressBarDuration;

@end

#pragma mark - Implementation

@implementation PBMVideoView

#pragma mark - Properties

+ (Class)layerClass {
    return AVPlayerLayer.self;
}

- (AVPlayer *)avPlayer {
    AVPlayerLayer *layer = (AVPlayerLayer *)self.layer;
    return layer.player;
}

- (void)setAvPlayer:(AVPlayer *)avPlayer {
    AVPlayerLayer *layer = (AVPlayerLayer *)self.layer;
    layer.player = avPlayer;
}

- (PBMAdConfiguration *)adConfiguration {
    return self.creative.creativeModel.adConfiguration;
}

#pragma mark - Initialization

- (instancetype)initWithEventManager:(PBMEventManager *)eventManager {
    self = [super init];
    if (self) {
        [self setupWithEventManager:eventManager];
        self.progressBarDuration = [self calculateProgressBarDuration];
    }
    
    return self;
}

- (instancetype)initWithCreative:(PBMVideoCreative *)creative {
    CGRect frame = CGRectMake(0.0, 0.0, creative.creativeModel.width, creative.creativeModel.height);

    self = [super initWithFrame:frame];
    if (self) {
        self.creative = creative;
        [self setupWithEventManager:creative.eventManager];
        self.progressBarDuration = [self calculateProgressBarDuration];
    }
    
    return self;
}

- (void)dealloc {
    PBMLogWhereAmI();
    
    [NSNotificationCenter.defaultCenter removeObserver:self];
    
    if (self.avPlayer) {
        [self.avPlayer.currentItem removeObserver:self forKeyPath:PBMAVPlayerObserverKeyStatus];
        [self.avPlayer removeObserver:self forKeyPath:PBMAVPlayerObserverKeyVolume];
        
        if (self.timeObserver) {
            [self.avPlayer removeTimeObserver:self.timeObserver];
        }
        
        [self.avPlayer pause];
        
        [AVAudioSession.sharedInstance removeObserver:self forKeyPath:PBMAudioSessionObserverKeyVoulume];
    }
}

- (void)setupWithEventManager:(PBMEventManager *)eventManager {
    self.isPlaybackFinished = NO;
    self.showLearnMore = NO;
    self.isPlaybackStarted = NO;
    self.eventManager = eventManager;
    self.accessibilityIdentifier = @"PBMVideoView";
    
    if (!self.creative.creativeModel.adConfiguration.isInterstitialAd ||
        (!self.creative.creativeModel.adConfiguration.isRewarded)) {
        [self setupTapRecognizer];
    }
    
    [self setupSkipButton];
    
    self.isSoundButtonVisible = self.creative.creativeModel.adConfiguration.videoControlsConfig.isSoundButtonVisible;
}

#pragma mark - Public

- (void)showMediaFileURL:(NSURL *)mediaFileURL preloadedData:(NSData *)preloadedData {
    PBMLogWhereAmI();
    PBMAssert(mediaFileURL && preloadedData);
    if (!(mediaFileURL )) {
        return;
    }

    self.preloadedData = preloadedData;
    
    //Pass it to an AVURLAsset via AVAssetResourceLoaderDelegate
    NSURL *dummyURL = [NSURL URLWithString:@"dummy://url"];
    AVURLAsset *avURLAsset = [AVURLAsset URLAssetWithURL:dummyURL options:nil];
    
    dispatch_queue_t queue = dispatch_queue_create("avResourceLoader", nil);
    [avURLAsset.resourceLoader setDelegate:self queue:queue];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:avURLAsset];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.avPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        
        [self.avPlayer addObserver:self forKeyPath:PBMAVPlayerObserverKeyVolume options:NSKeyValueObservingOptionNew context:nil];
    });
    
    // Add Observers
    [self setupObserversWithPlayerItem:playerItem];
}

- (void)updateControls {
    [self updateLearnMoreButtonVisibility];
    [self updateLearnMoreButton];
    
    [self resetMuteControls];
    [self updateMuteControls];

    [self updateProgressBar];
}

- (void)updateLearnMoreButtonVisibility {
    
    if (!self.videoViewDelegate) {
        // We have no way to respond to the Learn More button click
        // Is used to show the MRAID video.
        self.showLearnMore = NO;
        return;
    }
    
    if (!self.creative.creativeModel.adConfiguration.presentAsInterstitial) {
        self.showLearnMore = NO;
        return;
    }
    
    // For rewarded ad learn more should be hidden
    if (self.creative.creativeModel.adConfiguration.isRewarded) {
        self.showLearnMore = NO;
        return;
    }
    
    PBMCreativeModel *creativeModel = self.creative.creativeModel;
    
    BOOL hasCompanionAd = creativeModel.hasCompanionAd || creativeModel.isCompanionAd;

    /*
     If this interstitial video ad has companions or is a companion ad,
     do not show a learn more button during the video, and only show the end card
    
     Since rewarded video ads can have companions (i.e. the current creative is the primary
     rewarded ad and has companions) or is a companion ad (i.e. we've displayed the primary and
     now we're displaying as series of 1 or more companions) we'll show the learn more only
     at the end.
     */
    self.showLearnMore = hasCompanionAd ? NO : YES;
}

- (void)setupObserversWithPlayerItem:(AVPlayerItem *)playerItem {
    //This will fire when the view is ready to play or fails
    [playerItem addObserver:self forKeyPath:PBMAVPlayerObserverKeyStatus options:NSKeyValueObservingOptionInitial context:nil];
    
    // This will fire when end of content is reached
    // NOTE: there is a possibility of duplicate notification
    // https://stackoverflow.com/questions/16248496/observer-in-nsnotification-itemdidfinishplaying-randomly-to-called-twice
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(observer_AVPlayerItemDidPlayToEndTimeNotification:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:playerItem];
    
    [AVAudioSession.sharedInstance setActive:YES error:nil];
    [AVAudioSession.sharedInstance addObserver:self forKeyPath:PBMAudioSessionObserverKeyVoulume options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    if (!self.preloadedData) {
        [loadingRequest finishLoadingWithError:[PBMError errorWithDescription:@"data was not pre-fetched"]];
        return false;
    }
    
    AVAssetResourceLoadingDataRequest *dataRequest = loadingRequest.dataRequest;
    if (!dataRequest) {
        [loadingRequest finishLoadingWithError:[PBMError errorWithDescription:@"No data request"]];
        return false;
    }
    
    NSUInteger dataLength = self.preloadedData ? self.preloadedData.length : 0;
    if (dataLength == 0) {
        [loadingRequest finishLoadingWithError:[PBMError errorWithDescription:@"preloadedData is empty!"]];
        return false;
    }
    
    //Get the subset of data to send.
    //Typically the first request wants the first 2 bytes, then a subsequent request will ask for all the bytes.
    NSInteger start = (NSInteger)dataRequest.requestedOffset;
    NSInteger end = start + dataRequest.requestedLength;
    NSRange range = NSMakeRange(start, dataRequest.requestedLength);
    
    if (end > dataLength) {
        NSString *message = [NSString stringWithFormat:@"Requested range of %@ goes past the end of preloadedData (length is %ld)", NSStringFromRange(range), (unsigned long)dataLength];
        [loadingRequest finishLoadingWithError:[PBMError errorWithDescription:message]];
        return false;
    }
    
    NSData *dataToSend = [self.preloadedData subdataWithRange:range];
    
    //Convert the MIMEType to a UTI
    //TODO: This always identifies the preloaded file as an mp4. This works (since it's already passed other checks) but should
    //be updated to use its true mimetype.
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (CFStringRef) @"video/mp4", nil);
    if (contentType) {
        NSString *strContentType = (NSString *)CFBridgingRelease(contentType);
        [loadingRequest.contentInformationRequest setContentType:strContentType];
        [loadingRequest.contentInformationRequest setByteRangeAccessSupported:YES];
    }
    
    //Send the full length of the content (Note that this is not neccessarily the amount of data being sent!)
    [loadingRequest.contentInformationRequest setContentLength:dataLength];
    [loadingRequest.dataRequest respondWithData:dataToSend];
    
    //Tell the request that we are finished sending data for now.
    [loadingRequest finishLoading];
    
    //If all data is transfered to the player we can free the memory for preloaded data.
    self.requestedDataLength += range.length;
    if (self.requestedDataLength == dataLength) {
        self.preloadedData = nil;
        self.requestedDataLength = 0;
    }
    
    return YES;
}

#pragma mark - PBMModalManagerDelegate

- (void)modalManagerDidFinishPop:(PBMModalState*)state {
    if (self.creative != nil) {
        [self.creative resume];
    } else {
        [self resume]; // MRAID video
    }
}

- (void)modalManagerDidLeaveApp:(PBMModalState*)state {
    [self.creative modalManagerDidLeaveApp:state];
}

#pragma mark - View buttons

- (void)updateLearnMoreButton {
    if (self.btnLearnMore) {
        [self.btnLearnMore removeFromSuperview];
    }
    
    if (!self.showLearnMore) {
        return;
    }
    
    self.btnLearnMore = [self createButtonWithTitile:PBMLearnMoreButtonTitle action:@selector(btnLearnMoreClick)];
    [self addSubview:self.btnLearnMore];

    [self.btnLearnMore PBMAddBottomRightConstraintsWithMarginSize:CGSizeMake(-25.0, -25.0)];
}

- (void)updateProgressBar {
    if (self.progressBar) {
        [self.progressBar removeFromSuperview];
    }
    
    if (!self.creative.creativeModel.adConfiguration.isRewarded) {
        return;
    }
    
    PBMCircularProgressBarView *progressBar = [[PBMCircularProgressBarView alloc] initWithFrame:CGRectMake(30,60, 36, 36)];
    progressBar.emptyCapType = 1;
    
    progressBar.valueFontName = @".SFUIText-Medium";
    progressBar.valueFontSize = 16;
    progressBar.fontColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    
    progressBar.progressLineWidth = 2;
    progressBar.progressLinePadding = 1;
    progressBar.progressColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    
    progressBar.backgroundColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.75];
    
    [self addSubview:progressBar];
    [progressBar PBMAddBottomLeftConstraintsWithViewSize:CGSizeMake(36, 36) marginSize:CGSizeMake(25.0, -25.0)];
    
    self.progressBar = progressBar;
}

- (void)updateWatchAgainButton {
    if (self.btnWatchAgain) {
        [self.btnWatchAgain removeFromSuperview];
    }
    
    self.btnWatchAgain = [self createButtonWithTitile:PBMWatchAgainButtonTitle action:@selector(btnWatchAgainClick)];
    [self addSubview:self.btnWatchAgain];
    
    [self.btnWatchAgain PBMAddCropAndCenterConstraintsWithInitialWidth:self.btnWatchAgain.frame.size.width initialHeight:self.btnWatchAgain.frame.size.height];
}

- (void)resetMuteControls {
    [self.muteControlsView removeFromSuperview];
    self.muteControlsView = nil;
}

- (void)setupMuteControls {
    if (self.muteControlsView) {
        return;
    }
    
    if (!self.isSoundButtonVisible) {
        return;
    }
    
    UIButton * const muteButton = [self createButtonWithString:PrebidImagesRepository.muteDisabled
                                            accessibilityLabel:@"pbmMute"
                                                        action:@selector(btnMuteClick:)];
    
    UIButton * const unmuteButton = [self createButtonWithString:PrebidImagesRepository.muteEnabled
                                              accessibilityLabel:@"pbmUnmute"
                                                          action:@selector(btnUnmuteClick:)];
    
    muteButton.translatesAutoresizingMaskIntoConstraints = NO;
    unmuteButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView * const muteControlsView = [[UIView alloc] init];
    muteControlsView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [muteControlsView addSubview:muteButton];
    [muteControlsView addSubview:unmuteButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [muteControlsView.widthAnchor constraintEqualToConstant:MUTE_BUTTON_SIZE.width],
        [muteControlsView.heightAnchor constraintEqualToConstant:MUTE_BUTTON_SIZE.height],
        
        [muteButton.centerXAnchor constraintEqualToAnchor:muteControlsView.centerXAnchor],
        [muteButton.centerYAnchor constraintEqualToAnchor:muteControlsView.centerYAnchor],
        [muteButton.widthAnchor constraintLessThanOrEqualToAnchor:muteControlsView.widthAnchor],
        [muteButton.heightAnchor constraintLessThanOrEqualToAnchor:muteControlsView.heightAnchor],
        
        [unmuteButton.centerXAnchor constraintEqualToAnchor:muteControlsView.centerXAnchor],
        [unmuteButton.centerYAnchor constraintEqualToAnchor:muteControlsView.centerYAnchor],
        [unmuteButton.widthAnchor constraintLessThanOrEqualToAnchor:muteControlsView.widthAnchor],
        [unmuteButton.heightAnchor constraintLessThanOrEqualToAnchor:muteControlsView.heightAnchor],
    ]];
    
    [self addSubview:muteControlsView];
    if (self.creative.creativeModel.adConfiguration.presentAsInterstitial) {
        [NSLayoutConstraint activateConstraints:@[
            [muteControlsView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:25],
            [muteControlsView.topAnchor constraintEqualToAnchor:self.topAnchor constant:18],
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [muteControlsView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0],
            [muteControlsView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0],
        ]];
    }
    
    self.btnMute = muteButton;
    self.btnUnmute = unmuteButton;
    self.muteControlsView = muteControlsView;
}

- (void)updateMuteControls {
    if (!self.muteControlsView) {
        [self setupMuteControls];
    }
    BOOL const muted = self.muted;
    self.btnMute.hidden = muted;
    self.btnUnmute.hidden = !muted;
}

- (void)setupSkipButton {
    self.skipButtonDecorator = [PBMAdViewButtonDecorator new];
    self.skipButtonDecorator.button.hidden = YES;
    self.skipButtonDecorator.buttonArea = self.creative.creativeModel.adConfiguration.videoControlsConfig.skipButtonArea;
    self.skipButtonDecorator.buttonPosition = self.creative.creativeModel.adConfiguration.videoControlsConfig.skipButtonPosition;
    
    UIImage *skipButtonImage = PrebidImagesRepository.skipButton.base64DecodedImage;
    
    [self.skipButtonDecorator setImage:skipButtonImage];
    [self.skipButtonDecorator addButtonTo:self displayView:self];
    
    @weakify(self);
    self.skipButtonDecorator.buttonTouchUpInsideBlock = ^{
        @strongify(self);
        if (!self) { return; }
        
        [self skipButtonTapped];
    };
}

- (void)skipButtonTapped {
    [self.skipButtonDecorator removeButtonFromSuperview];
    [self.avPlayer pause];
    [self completeVideoViewDisplayWith:PBMTrackingEventSkip];
}

- (void)handleSkipDelay:(NSTimeInterval)skipDelay videoDuration:(NSTimeInterval)videoDuration {
    if (skipDelay >= videoDuration) {
        return;
    }
    
    if (!self.creative.creativeModel.hasCompanionAd ||
        self.creative.creativeModel.adConfiguration.isRewarded ||
        self.creative.creativeModel.adConfiguration.isBuiltInVideo) {
        return;
    }
    
    dispatch_time_t dispatchTime = [PBMFunctions dispatchTimeAfterTimeInterval:self.creative.creativeModel.adConfiguration.videoControlsConfig.skipDelay];
    @weakify(self);
    dispatch_after(dispatchTime, dispatch_get_main_queue(), ^{
        @strongify(self);
        if (self == nil) {
            return;
        }
        
        self.skipButtonDecorator.button.hidden = NO;
    });
}

- (UIButton *)createButtonWithString:(NSString *)encodedString
                  accessibilityLabel:(NSString *)accessibilityLabel
                              action:(SEL)action
{
    UIButton * const button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor clearColor];
    [button setImage:encodedString.base64DecodedImage forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button setIsAccessibilityElement:YES];
    [button setAccessibilityLabel:accessibilityLabel];
    button.layer.cornerRadius = 5;
    button.layer.backgroundColor = [[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.75] CGColor];
    [button sizeToFit];
    
    return button;
}

- (UIButton *)createButtonWithTitile:(NSString *)title action:(SEL)action {
    UIButton *btnLearnMore = [UIButton new];
    btnLearnMore.backgroundColor = [UIColor clearColor];
    [btnLearnMore setTitle:title forState:UIControlStateNormal];
    [btnLearnMore addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [btnLearnMore setIsAccessibilityElement:YES];
    [btnLearnMore setAccessibilityLabel:title];
    
    btnLearnMore.layer.cornerRadius = 5;
    btnLearnMore.layer.borderWidth = 2;
    
    btnLearnMore.layer.borderColor = [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] CGColor];
    btnLearnMore.layer.backgroundColor = [[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:0.75] CGColor];
    
    UIFont *font = [UIFont fontWithName:@".SFUIText-Medium" size:16.0];
    if (!font) {
        if (@available(iOS 8.2, *)) {
            font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        } else {
            font = [UIFont systemFontOfSize:16];
        }
    }
    
    btnLearnMore.titleLabel.font = font;
    
    btnLearnMore.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
    [btnLearnMore sizeToFit];
    
    return btnLearnMore;
}

#pragma mark - Button Events

- (void)btnLearnMoreClick {
    [self.videoViewDelegate learnMoreWasClicked];
}

- (void)btnWatchAgainClick {
    self.isPlaybackFinished = NO;

    [self.avPlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.avPlayer play];
    
    [self.btnWatchAgain removeFromSuperview];
    self.btnWatchAgain = nil;
    
    [self trackStartPlaybackEvents];
}

- (void)btnMuteClick:(UIButton *)button {
    [self mute];
    
    if ([self.creative.creativeViewDelegate respondsToSelector:@selector(videoWasMuted:)]) {
        [self.creative.creativeViewDelegate videoWasMuted:self.creative];
    }
}

- (void)btnUnmuteClick:(UIButton *)button {
    [self unmute];
    
    if ([self.creative.creativeViewDelegate respondsToSelector:@selector(videoWasUnmuted:)]) {
        [self.creative.creativeViewDelegate videoWasUnmuted:self.creative];
    }
}

#pragma mark - Interface

- (void)startPlayback {
    PBMLogWhereAmI();
    
    if (!self.avPlayer) {
        PBMLogError(@"Attempted to display a VideoView with no avPlayer");
        return;
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(observer_UIApplicationWillResignActive:)
                                               name:UIApplicationWillResignActiveNotification
                                             object:UIApplication.sharedApplication];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(observer_UIApplicationDidBecomeActive:)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:UIApplication.sharedApplication];
    
    [self updateControls];
    [self initTimeObserver];

    [self.avPlayer play];
    
    [self handleSkipDelay:self.adConfiguration.videoControlsConfig.skipDelay
            videoDuration:self.creative.creativeModel.displayDurationInSeconds.doubleValue];

    if (!self.isPlaybackStarted) {
        self.isPlaybackStarted = YES;
        [self trackStartPlaybackEvents];
    }
}

- (void)initTimeObserver {
    //Create observer if it doesn't exist
    if (!self.timeObserver) {
        //Have the timeObserver fire 33 times per seconds
        CMTime thirtyThreeFPS = CMTimeMake(33,1000);
        @weakify(self);
        self.timeObserver = [self.avPlayer addPeriodicTimeObserverForInterval:thirtyThreeFPS queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            @strongify(self);
            if (!self) { return; }
            
            [self periodicTimeObserver];
        }];
    }
    
    if (self.adConfiguration.isRewarded) {
        self.progressBar.duration = [self.progressBarDuration doubleValue];
    }
}

- (void)pause {
    if (!self.avPlayer) {
        PBMLogError(@"Attempted to pause a VideoView with no avPlayer");
        return;
    }

    if (self.avPlayer.error || self.isPlaybackFinished) {
        return;
    }
    
    [self.avPlayer pause];
    [self.eventManager trackEvent:PBMTrackingEventPause];
}

- (void)resume {
    if (!self.avPlayer) {
        PBMLogError(@"Attempted to pause a VideoView with no avPlayer");
        return;
    }

    if (self.avPlayer.error || self.isPlaybackFinished) {
        return;
    }
    
    [self.avPlayer play];
    [self.eventManager trackEvent:PBMTrackingEventResume];
}

- (void)stop {
    [self stopWithTrackingEvent:PBMTrackingEventSkip];
}

- (void)stopWithTrackingEvent:(PBMTrackingEvent)trackingEvent {
    if (!self.avPlayer) {
        PBMLogError(@"No AVPlayer to stop");
        return;
    }
    
    [self.avPlayer pause];
    [self.eventManager trackEvent:trackingEvent];
    [self.videoViewDelegate videoViewCompletedDisplay];
}

- (void)mute {
    [self setMuted:YES];
}

- (void)unmute {
    [self setMuted:NO];
}

- (void)setMuted:(BOOL)muted {
    [self.avPlayer setMuted:muted];
    [self updateMuteControls];
}

- (BOOL)isMuted {
    return [self.avPlayer isMuted];
}

// handles scenario when the user presses the close button before the video has ended.
// Triggers the tracking event but purposely does not call videoViewCompletedDisplay method
// since the video hasn't finished displaying.
- (void)stopOnCloseButton:(PBMTrackingEvent)trackingEvent {
    if (!self.avPlayer) {
        PBMLogError(@"No AVPlayer to stop");
        return;
    }
    
    [self.avPlayer pause];
    [self.eventManager trackEvent:trackingEvent];
}

- (void)addFriendlyObstructionsToMeasurementSession:(PBMOpenMeasurementSession *)session {
    [session addFriendlyObstruction:self.btnLearnMore purpose:PBMOpenMeasurementFriendlyObstructionVideoViewLearnMoreButton];
    [session addFriendlyObstruction:self.progressBar purpose:PBMOpenMeasurementFriendlyObstructionVideoViewProgressBar];
}

#pragma mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:PBMAVPlayerObserverKeyStatus]) {
        [self onPlayerStatusChanged];
    }
    else if ([keyPath isEqualToString:PBMAVPlayerObserverKeyVolume] && object == self.avPlayer) {
        [self onPlayerVolumeChanged];
    }
    else if ([keyPath isEqualToString:PBMAudioSessionObserverKeyVoulume]) {
        [self onDeviceVolumeChanged];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)observer_UIApplicationWillResignActive:(NSNotification *)notification {
    [self pause];
}

- (void)observer_UIApplicationDidBecomeActive:(NSNotification *)notification {
    [self resume];
}

- (void)observer_AVPlayerItemDidPlayToEndTimeNotification:(NSNotification *)notification {
    [self handleDidPlayToEndTime];
}

- (void)completeVideoViewDisplayWith:(PBMTrackingEvent)trackingEvent {

    if (!self.isPlaybackFinished ) {
        self.isPlaybackFinished = YES;
        [self.eventManager trackEvent:trackingEvent];
    }
    
    [self.videoViewDelegate videoViewCompletedDisplay];
    
    if (self.adConfiguration.isRewarded) {
        self.progressBar.hidden = YES;
    }
    
    if (self.adConfiguration.isBuiltInVideo && !self.creative.creativeModel.hasCompanionAd) {
        // UI: need to give some time to hide the interstitial before showing the Watch Again
        if (self.adConfiguration.presentAsInterstitial) {
            @weakify(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self);
                if (!self) { return; }
                
                [self updateWatchAgainButton];
            });
        } else {
            [self updateWatchAgainButton];
        }
    }
}

- (void)handleDidPlayToEndTime {
    if (self.isPlaybackFinished) {
        return;
    }
    
    [self completeVideoViewDisplayWith:PBMTrackingEventComplete];
}

/*
    This method is called by the avPlayer so we can do following:
        1) send events to track progress.
        2) compare VAST Duration with actual video playing time
*/
- (void)periodicTimeObserver {
    [self handlePeriodicTimeEvent];
}

- (CGFloat)handlePeriodicTimeEvent {
    if (!self.avPlayer) {
        return 0;
    }
    
    // Grab the time at the moment and the time that this media will end at
    CMTime currentTime = self.avPlayer.currentTime;
    CMTime endTime = CMTimeConvertScale(self.avPlayer.currentItem.asset.duration, currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
    if (CMTimeCompare(endTime, kCMTimeZero)) {
        // calculate the current percent complete
        CGFloat playbackPercent = (CGFloat)currentTime.value / (CGFloat)endTime.value;
        
        if (self.previousCompletetionPercentage < 0.25 && playbackPercent >= 0.25) {
            [self.eventManager trackEvent:PBMTrackingEventFirstQuartile];
            PBMLogInfo(@"Video Playback Progress: PBMTrackingEventFirstQuartile");
        }

        if (self.previousCompletetionPercentage < 0.50 && playbackPercent >= 0.50) {
            [self.eventManager trackEvent:PBMTrackingEventMidpoint];
            PBMLogInfo(@"Video Playback Progress: PBMTrackingEventMidpoint");
        }
        
        if (self.previousCompletetionPercentage < 0.75 && playbackPercent >= 0.75) {
            [self.eventManager trackEvent:PBMTrackingEventThirdQuartile];
            PBMLogInfo(@"Video Playback Progress: PBMTrackingEventThirdQuartile");
        }
        
        self.previousCompletetionPercentage = playbackPercent;
    }
    
    CGFloat playingTime = CMTimeGetSeconds(currentTime);
    CGFloat remainingTime = [self.progressBarDuration doubleValue] - playingTime;

    if (self.creative.creativeModel.adConfiguration.isRewarded) {
        
        // Update progress bar
        if(remainingTime >= 0) {
            [self.progressBar updateProgress:remainingTime];
        } else {
            if (self.progressBar.superview) {
                [self.progressBar removeFromSuperview];
            }
        }
    }
    
    [self.videoViewDelegate videoViewCurrentPlayingTime:[NSNumber numberWithDouble:playingTime]];
    
    [self stopAdIfNeeded];

    return remainingTime;
}

- (CGFloat)requiredVideoDuration {
    // The countdown timer and video duration should correspond to the general rule of VAST ads:
    // We should use the shorter of the 2: VAST duration and video duration.
    
    CGFloat videoDuration = (CGFloat)CMTimeGetSeconds(self.avPlayer.currentItem.asset.duration);
    CGFloat vastDuration = [self.creative.creativeModel.displayDurationInSeconds doubleValue];
    return MIN(videoDuration, vastDuration);
}

- (void)trackStartPlaybackEvents {
    [self.eventManager trackEvent:PBMTrackingEventNormal];
    
    [self.eventManager trackEvent:PBMTrackingEventCreativeView];
    
    [self.eventManager trackStartVideoWithDuration:self.avPlayer.currentItem.asset.duration.value
                                            volume:self.avPlayer.volume];
    
    PBMLogInfo(@"Video Playback Progress: PBMTrackingEventCreativeView/PBMTrackingEventStart");
}

// pause avPlayer and notify videoViewCompletedDisplay if video reached the VAST Duration
- (void)stopAdIfNeeded {
    
    if (self.isPlaybackFinished) {
        return;
    }
    
    if (!self.avPlayer) {
        return;
    }
    
    NSTimeInterval vastDuration = [self.creative.creativeModel.displayDurationInSeconds doubleValue];
    if (!vastDuration) {
        return;
    }
    
    AVPlayerItem *currentItem = self.avPlayer.currentItem;
    CGFloat playerCurrentTime = CMTimeGetSeconds(currentItem.currentTime);
    if (playerCurrentTime >= vastDuration) {
        [self.avPlayer pause];
        [self completeVideoViewDisplayWith:PBMTrackingEventComplete];
    }
}

#pragma mark - Helper Methods

- (void)onPlayerStatusChanged {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        
        if (!self) { return; }
        
        if (self.avPlayer && self.avPlayer.currentItem) {
            switch (self.avPlayer.status) {
                case AVPlayerStatusReadyToPlay: {
                    PBMLogInfo(@"readyToPlay");
                    [self.videoViewDelegate videoViewReadyToDisplay];
                    return;
                }
                break;
                    
                case AVPlayerStatusUnknown : {
                    PBMLogInfo(@"unknown (This is normal at launch)");
                    return;
                }
                break;
                    
                case AVPlayerStatusFailed: {
                    NSError *error = self.avPlayer.currentItem.error ?: [PBMError errorWithDescription:@"Unknown Error"];
                    [self.videoViewDelegate videoViewFailedWithError:error];
                }
                break;
            }
        }
    });
}

- (void)onPlayerVolumeChanged {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        
        if (!self) { return; }
        
        CGFloat newVolume = self.avPlayer.volume;
        if (!self.isInitialVolumeTracked) {
            self.isInitialVolumeTracked = [NSNumber numberWithFloat:self.avPlayer.volume];
        }
        else if (newVolume != self.isInitialVolumeTracked.floatValue) {
            [self.eventManager trackVolumeChanged:newVolume deviceVolume:AVAudioSession.sharedInstance.outputVolume];
        }
    });
}

- (void)onDeviceVolumeChanged {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        
        if (!self) { return; }
        
        [self.eventManager trackVolumeChanged:self.avPlayer.volume deviceVolume:AVAudioSession.sharedInstance.outputVolume];
    });
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Utilities

- (NSString *)getStringFromCMTime:(CMTime)time {
    CGFloat seconds = CMTimeGetSeconds(time);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.dateFormat = @"mm:ss";
    
    return [dateFormatter stringFromDate:date];
}

- (void)resetControls {
    if (self.progressBar) {
        [self.progressBar removeFromSuperview];
        self.progressBar = nil;
    }
    
    if (self.btnLearnMore) {
        // remove previous instance of the button
        [self.btnLearnMore removeFromSuperview];
    }
    
    [self resetMuteControls];
}

- (void)setupTapRecognizer {
    if (self.tapdownGestureRecognizer) {
        [self removeGestureRecognizer:self.tapdownGestureRecognizer];
    }
    
    self.tapdownGestureRecognizer = [[PBMTouchDownRecognizer alloc] initWithTarget:self action:@selector(recordTapEvent:)];
    [self.tapdownGestureRecognizer setCancelsTouchesInView:YES];
    [self addGestureRecognizer:self.tapdownGestureRecognizer];
    self.tapdownGestureRecognizer.delegate = self;
}

- (void)recordTapEvent:(UITapGestureRecognizer *)tap {
    if (self.tapdownGestureRecognizer != tap) {
        return;
    }
    
    if (ENABLE_OUTSTREAM_TAP_TO_EXPAND) {
        [self.videoViewDelegate videoViewWasTapped];
    } else {
        if (!self.showLearnMore) {
            [self btnLearnMoreClick];
        }
    }
}

- (NSNumber *)calculateProgressBarDuration {
    // Get video duration
    CGFloat videoDuration = [self requiredVideoDuration];
    
    // If creative is not rewarded or has companion ad - return video duration.
    if (!self.creative.creativeModel.adConfiguration.isRewarded ||
        self.creative.creativeModel.hasCompanionAd) {
        return [NSNumber numberWithDouble:videoDuration];
    }
    
    PBMRewardedConfig * rewardedConfig = self.creative.creativeModel.adConfiguration.rewardedConfig;
    
    NSString * ortbPlaybackevent = rewardedConfig.videoPlaybackevent;
    NSNumber * ortbVideoTime = rewardedConfig.videoTime;
    NSNumber * ortbPostrewardedTime = rewardedConfig.postRewardTime ?: 0;
    
    // If both completion criteria are missing (playbackevent and time) - use default configuration
    if (!ortbPlaybackevent && !ortbVideoTime) {
        ortbPlaybackevent = rewardedConfig.defaultVideoPlaybackEvent;
    }
    
    double progressBarDuration = ([ortbPostrewardedTime doubleValue] >= 0) ? [ortbPostrewardedTime doubleValue] : 0.0;
    
    // If completion criteria is playback event
    if (ortbPlaybackevent) {
        PBMTrackingEvent event = [PBMTrackingEventDescription getEventWith:ortbPlaybackevent];
    
        switch(event) {
            case PBMTrackingEventStart:
                break;
            case PBMTrackingEventFirstQuartile:
                progressBarDuration += 0.25 * videoDuration;
                break;
            case PBMTrackingEventMidpoint:
                progressBarDuration += 0.5 * videoDuration;
                break;
            case PBMTrackingEventThirdQuartile:
                progressBarDuration += 0.75 * videoDuration;
                break;
            case PBMTrackingEventComplete:
                progressBarDuration = videoDuration;
                break;
            default:
                break;
        }
        
        // if calculated value is bigger than video duration => return video duration
        return (progressBarDuration > videoDuration) ? [NSNumber numberWithDouble:videoDuration] :
        [NSNumber numberWithDouble:progressBarDuration];
    }
    
    // If completion criteria is time
    if (ortbVideoTime && [ortbVideoTime doubleValue] >= 0.0) {
        progressBarDuration += [ortbVideoTime doubleValue];
        
        // if calculated value is bigger than video duration => return video duration
        return (progressBarDuration > videoDuration) ? [NSNumber numberWithDouble:videoDuration] :
        [NSNumber numberWithDouble:progressBarDuration];
    }
    
    // Return video duration by default
    return [NSNumber numberWithDouble:[self requiredVideoDuration]];
}


@end
