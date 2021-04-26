//
//  PBMPlayable.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMPlayable <NSObject>

- (BOOL)canPlay;    // true if playable can start playing
- (void)play;       // to be ignored if playback has already started
- (void)pause;      // pause by user interraction
- (void)autoPause;  // pause automatically, i.e. when playable has became invisible
- (BOOL)canAutoResume;  // true if can be resumed automaticaly 
- (void)resume;

@end

NS_ASSUME_NONNULL_END
