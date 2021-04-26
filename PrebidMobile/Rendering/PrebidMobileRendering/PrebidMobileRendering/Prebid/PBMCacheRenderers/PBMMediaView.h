//
//  PBMMediaView.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import UIKit;

#import "PBMMediaViewDelegate.h"

@class PBMMediaData;

NS_ASSUME_NONNULL_BEGIN

@interface PBMMediaView : UIView

IBInspectable @property (atomic, assign) BOOL autoPlayOnVisible;
IBInspectable @property (atomic, weak, nullable) id<PBMMediaViewDelegate> delegate;

@property (atomic, readonly) BOOL isMediaLoaded;
@property (atomic, nullable, readonly) PBMMediaData *mediaData;

- (void)loadMedia:(PBMMediaData *)mediaData;

- (void)mute;
- (void)unmute;

- (void)play;

- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END
