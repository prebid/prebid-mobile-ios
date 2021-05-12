//
//  MPNativeAdConfigValues+Internal.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPNativeAdConfigValues+Internal.h"

@implementation MPNativeAdConfigValues (Internal)

- (BOOL)isValidPercentage:(CGFloat)percentage
{
    return (percentage >= 0.0 && percentage <= 1.0);
}

- (BOOL)isValidTimeInterval:(NSTimeInterval)timeInterval
{
    return timeInterval > 0.0;
}

- (BOOL)isValidNumberOfPixels:(CGFloat)pixels {
    return pixels >= 0.0;
}

@end
