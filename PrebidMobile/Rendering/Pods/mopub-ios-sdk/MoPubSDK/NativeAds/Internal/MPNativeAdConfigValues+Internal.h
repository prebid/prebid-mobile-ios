//
//  MPNativeAdConfigValues+Internal.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPNativeAdConfigValues.h"

@interface MPNativeAdConfigValues (Internal)

- (BOOL)isValidPercentage:(CGFloat)percentage;
- (BOOL)isValidTimeInterval:(NSTimeInterval)timeInterval;
- (BOOL)isValidNumberOfPixels:(CGFloat)pixels;

@end
