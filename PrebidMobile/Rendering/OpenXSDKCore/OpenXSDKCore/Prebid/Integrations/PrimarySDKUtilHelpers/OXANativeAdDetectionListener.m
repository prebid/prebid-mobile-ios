//
//  OXANativeAdDetectionListener.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeAdDetectionListener.h"

@implementation OXANativeAdDetectionListener

- (instancetype)initWithNativeAdLoadedHandler:(nullable OXANativeAdLoadedHandler)onNativeAdLoaded
                               onPrimaryAdWin:(nullable OXAPrimaryAdServerWinHandler)onPrimaryAdWin
                            onNativeAdInvalid:(nullable OXAInvalidNativeAdHandler)onNativeAdInvalid
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
