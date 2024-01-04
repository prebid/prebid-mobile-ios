/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

#import "GAMOriginalAPIVideoInstreamViewController.h"
#import "PrebidDemoMacros.h"

@import PrebidMobile;

NSString * const videoContentURL = @"https://storage.googleapis.com/gvabox/media/samples/stock.mp4";
NSString * const storedImpVideo = @"prebid-demo-video-interstitial-320-480-original-api";
NSString * const gamAdUnitVideo = @"/21808260008/prebid_demo_app_instream";

@interface GAMOriginalAPIVideoInstreamViewController ()

// Prebid
@property (nonatomic) InstreamVideoAdUnit * adUnit;

// IMA
@property (nonatomic) IMAAdsLoader * adsLoader;
@property (nonatomic) IMAAdsManager * adsManager;
@property (nonatomic) IMAAVPlayerContentPlayhead * contentPlayhead;

@property (nonatomic, nullable) AVPlayer * contentPlayer;
@property (nonatomic, nullable) AVPlayerLayer * playerLayer;

@end

@implementation GAMOriginalAPIVideoInstreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.instreamView.backgroundColor = [UIColor clearColor];
    self.playButton.layer.zPosition = DBL_MAX;
    
    NSURL * contentURL = [NSURL URLWithString:videoContentURL];
    
    self.contentPlayer = [[AVPlayer alloc] initWithURL:contentURL];
    
    // Create a player layer for the player.
    self.playerLayer = [[AVPlayerLayer alloc] init];
    self.playerLayer.player = self.contentPlayer;
    
    // Size, position, and display the AVPlayer.
    self.playerLayer.frame = self.instreamView.layer.bounds;
    [self.instreamView.layer addSublayer:self.playerLayer];
    
    // Set up our content playhead and contentComplete callback.
    self.contentPlayhead = [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:self.contentPlayer];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(contentDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.contentPlayer.currentItem];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.playerLayer.frame = self.instreamView.layer.bounds;
    [self.adsManager destroy];
    [self.contentPlayer pause];
    self.contentPlayer = nil;
}

- (void)contentDidFinishPlaying: (NSNotification*)notification {
    // Make sure we don't call contentComplete as a result of an ad completing.
    if ([notification.object isKindOfClass:[AVPlayerItem class]] && notification.object == self.contentPlayer.currentItem) {
        [self.adsLoader contentComplete];
    }
}

- (void)onPlayButtonPressed:(id)sender {
    [super onPlayButtonPressed:sender];
    
    [self.playButton setHidden:YES];
    
    // Setup and load in-stream video
    [self createAd];
}

- (void)createAd {
    // 1. Create InstreamVideoAdUnit
    self.adUnit = [[InstreamVideoAdUnit alloc] initWithConfigId:storedImpVideo size:CGSizeMake(640, 480)];
    
    // 2. Configure Video Parameters
    VideoParameters * parameters = [[VideoParameters alloc] initWithMimes:@[@"video/mp4"]];
    parameters.protocols = @[PBProtocols.VAST_2_0];
    parameters.playbackMethod = @[PBPlaybackMethod.AutoPlaySoundOff];
    self.adUnit.videoParameters = parameters;
    
    // 3. Prepare IMAAdsLoader
    self.adsLoader = [[IMAAdsLoader alloc] init];
    self.adsLoader.delegate = self;
    
    // 4. Make a bid request
    @weakify(self);
    [self.adUnit fetchDemandWithCompletion:^(enum ResultCode resultCode, NSDictionary<NSString *,NSString *> * _Nullable prebidKeys) {
        @strongify(self);
        if (!self) { return; }
        
        if (resultCode == ResultCodePrebidDemandFetchSuccess) {
            @try
            {
                // 5. Generate GAM Instream URI
                NSString * adServerTag = [IMAUtils.shared generateInstreamUriForGAMWithAdUnitID:gamAdUnitVideo adSlotSizes:@[IMAAdSlotSize.Size640x480] customKeywords:prebidKeys error:nil];
                
                // 6. Load IMA ad request
                IMAAdDisplayContainer * adDisplayContainer = [[IMAAdDisplayContainer alloc] initWithAdContainer:self.instreamView viewController:self];
                IMAAdsRequest * request = [[IMAAdsRequest alloc] initWithAdTagUrl:adServerTag adDisplayContainer:adDisplayContainer contentPlayhead:nil userContext:nil];
                [self.adsLoader requestAdsWithRequest:request];
            }
            @catch(id anException) {
                [self.contentPlayer play];
            }
        } else {
            [self.contentPlayer play];
        }
    }];
}

// MARK: - IMAAdsLoaderDelegate

- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
    self.adsManager = adsLoadedData.adsManager;
    self.adsManager.delegate = self;
    
    // Initialize the ads manager.
    [self.adsManager initializeWithAdsRenderingSettings:nil];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    PBMLogError(@"%@", adErrorData.adError.message);
    [self.contentPlayer play];
}

// MARK: - IMAAdsManagerDelegate

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    if (event.type == kIMAAdEvent_LOADED) {
        // When the SDK notifies us that ads have been loaded, play them.
        [self.adsManager start];
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    PBMLogError(@"%@", error.message);
    [self.contentPlayer play];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    // The SDK is going to play ads, so pause the content.
    [self.contentPlayer pause];
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    // The SDK is done playing ads (at least for now), so resume the content.
    [self.contentPlayer play];
}

@end
