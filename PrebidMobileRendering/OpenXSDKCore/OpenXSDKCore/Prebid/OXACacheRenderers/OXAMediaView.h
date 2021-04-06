//
//  OXAMediaView.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import UIKit;

#import "OXAMediaViewDelegate.h"

@class OXAMediaData;

NS_ASSUME_NONNULL_BEGIN

@interface OXAMediaView : UIView

IBInspectable @property (atomic, assign) BOOL autoPlayOnVisible;
IBInspectable @property (atomic, weak, nullable) id<OXAMediaViewDelegate> delegate;

@property (atomic, readonly) BOOL isMediaLoaded;
@property (atomic, nullable, readonly) OXAMediaData *mediaData;

- (void)loadMedia:(OXAMediaData *)mediaData;

- (void)mute;
- (void)unmute;

- (void)play;

- (void)pause;
- (void)resume;

@end

NS_ASSUME_NONNULL_END
