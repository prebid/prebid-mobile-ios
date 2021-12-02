//
//  MPVideoPlayerViewOverlay.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPVideoPlayerViewOverlay.h"

@interface MPVideoPlayerViewOverlayConfig ()

@property (nonatomic, strong) NSString *callToActionButtonTitle;
@property (nonatomic, assign) BOOL isRewardExpected;
@property (nonatomic, assign) BOOL isClickthroughAllowed;
@property (nonatomic, assign) BOOL hasCompanionAd;
@property (nonatomic, assign) BOOL enableEarlyClickthroughForNonRewardedVideo;

@end

@implementation MPVideoPlayerViewOverlayConfig

- (instancetype)initWithCallToActionButtonTitle:(NSString *)callToActionButtonTitle
                               isRewardExpected:(BOOL)isRewardExpected
                          isClickthroughAllowed:(BOOL)isClickthroughAllowed
                                 hasCompanionAd:(BOOL)hasCompanionAd
     enableEarlyClickthroughForNonRewardedVideo:(BOOL)enableEarlyClickthroughForNonRewardedVideo {
    self = [super init];
    if (self) {
        _callToActionButtonTitle = callToActionButtonTitle;
        _isRewardExpected = isRewardExpected;
        _isClickthroughAllowed = isClickthroughAllowed;
        _hasCompanionAd = hasCompanionAd;
        _enableEarlyClickthroughForNonRewardedVideo = enableEarlyClickthroughForNonRewardedVideo;
    }
    return self;
}

@end
