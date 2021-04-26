//
//  PBMMediaView+Internal.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMMediaView.h"
#import "PBMPlayable.h"

typedef NS_ENUM(NSInteger, PBMMediaViewState) {
    PBMMediaViewState_Undefined = 0,
    PBMMediaViewState_PlaybackNotStarted,
    PBMMediaViewState_Playing,
    PBMMediaViewState_PausedByUser,
    PBMMediaViewState_PausedAuto,
    PBMMediaViewState_PlaybackFinished,
};

@class PBMMediaData;

@interface PBMMediaView () <PBMPlayable>
@end
