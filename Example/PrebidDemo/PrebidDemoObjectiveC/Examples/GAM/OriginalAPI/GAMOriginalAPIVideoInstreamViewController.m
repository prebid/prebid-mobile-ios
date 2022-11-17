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
NSString * const storedResponseVideo = @"response-prebid-video-interstitial-320-480";
NSString * const storedImpVideo = @"imp-prebid-video-interstitial-320-480";
NSString * const gamAdUnitVideo = @"/21808260008/prebid_oxb_interstitial_video";

@interface GAMOriginalAPIVideoInstreamViewController ()

// Prebid
@property (nonatomic) VideoAdUnit * adUnit;

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
    Prebid.shared.storedAuctionResponse = storedResponseVideo;
    [self createAd];
}

- (void)createAd {
    VideoParameters * parameters = [[VideoParameters alloc] init];
    parameters.mimes = @[@"video/mp4"];
    parameters.protocols = @[PBProtocols.VAST_2_0];
    parameters.playbackMethod = @[PBPlaybackMethod.AutoPlaySoundOff];
    self.adUnit = [[VideoAdUnit alloc] initWithConfigId:storedImpVideo size:self.adSize];
    self.adUnit.parameters = parameters;
    
    self.adsLoader = [[IMAAdsLoader alloc] init];
    self.adsLoader.delegate = self;
    
    @weakify(self);
    [self.adUnit fetchDemandWithCompletion:^(enum ResultCode resultCode, NSDictionary<NSString *,NSString *> * _Nullable prebidKeys) {
        @strongify(self);
        if (resultCode == ResultCodePrebidDemandFetchSuccess) {
            // FIXME: problem with objc API
//            NSString * adServerTag = [IMAUtils.shared gene]
        }
    }];
    
}

@end
