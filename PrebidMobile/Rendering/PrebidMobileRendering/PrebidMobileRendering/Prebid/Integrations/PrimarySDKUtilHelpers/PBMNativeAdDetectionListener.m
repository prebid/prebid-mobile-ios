//
//  PBMNativeAdDetectionListener.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeAdDetectionListener.h"

@implementation PBMNativeAdDetectionListener

- (instancetype)initWithNativeAdLoadedHandler:(nullable PBMNativeAdLoadedHandler)onNativeAdLoaded
                               onPrimaryAdWin:(nullable PBMPrimaryAdServerWinHandler)onPrimaryAdWin
                            onNativeAdInvalid:(nullable PBMInvalidNativeAdHandler)onNativeAdInvalid
{
    if (!(self = [super init])) {
        return nil;
    }
    _onNativeAdLoaded = [onNativeAdLoaded copy];
    _onPrimaryAdWin = [onPrimaryAdWin copy];
    _onNativeAdInvalid = [onNativeAdInvalid copy];
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self; // safe due to immutability, like NSNumber
}

@end
