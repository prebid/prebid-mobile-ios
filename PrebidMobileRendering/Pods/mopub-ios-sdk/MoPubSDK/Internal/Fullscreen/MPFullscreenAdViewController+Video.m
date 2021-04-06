//
//  MPFullscreenAdViewController+Video.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPFullscreenAdViewController+Private.h"
#import "MPFullscreenAdViewController+Video.h"

@implementation MPFullscreenAdViewController (Video)

- (instancetype)initWithVideoURL:(NSURL *)videoURL videoConfig:(MPVideoConfig *)videoConfig {
    self = [self initWithAdContentType:MPAdContentTypeVideo];
    if (self) {
        self.adContainerView = [[MPAdContainerView alloc] initWithVideoURL:videoURL videoConfig:videoConfig];
        self.adContainerView.countdownTimerDelegate = self;
    }
    return self;
}

- (void)loadVideo {
    [self.adContainerView loadVideo];
}

- (void)playVideo {
    [self.adContainerView playVideo];
}

- (void)pauseVideo {
    [self.adContainerView pauseVideo];
}

- (void)stopVideo {
    [self.adContainerView stopVideo];
}

- (void)enableAppLifeCycleEventObservationForAutoPlayPause {
    [self.adContainerView enableAppLifeCycleEventObservationForAutoPlayPause];
}

- (void)disableAppLifeCycleEventObservationForAutoPlayPause {
    [self.adContainerView disableAppLifeCycleEventObservationForAutoPlayPause];
}

@end
