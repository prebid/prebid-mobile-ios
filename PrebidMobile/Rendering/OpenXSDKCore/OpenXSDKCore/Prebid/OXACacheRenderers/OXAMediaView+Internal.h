//
//  OXAMediaView+Internal.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAMediaView.h"
#import "OXAPlayable.h"

typedef NS_ENUM(NSInteger, OXAMediaViewState) {
    OXAMediaViewState_Undefined = 0,
    OXAMediaViewState_PlaybackNotStarted,
    OXAMediaViewState_Playing,
    OXAMediaViewState_PausedByUser,
    OXAMediaViewState_PausedAuto,
    OXAMediaViewState_PlaybackFinished,
};

@class OXAMediaData;

@interface OXAMediaView () <OXAPlayable>
@end
