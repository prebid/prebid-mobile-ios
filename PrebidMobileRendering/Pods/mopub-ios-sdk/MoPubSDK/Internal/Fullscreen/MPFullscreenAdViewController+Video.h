//
//  MPFullscreenAdViewController+Video.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPFullscreenAdViewController.h"
#import "MPVideoPlayer.h"
#import "MPVideoPlayerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPFullscreenAdViewController (Video)  <MPVideoPlayer>

@property (nonatomic, weak) id<MPVideoPlayerDelegate> videoPlayerDelegate; // backing storage at "+Private.h"

@end

NS_ASSUME_NONNULL_END
