//
//  MPNativeAdConfigValues.h
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>

@interface MPNativeAdConfigValues : NSObject

@property (nonatomic, readonly) CGFloat impressionMinVisiblePixels;
@property (nonatomic, readonly) CGFloat impressionMinVisiblePercent;
@property (nonatomic, readonly) NSTimeInterval impressionMinVisibleSeconds;

- (instancetype)initWithImpressionMinVisiblePixels:(CGFloat)impressionMinVisiblePixels
                       impressionMinVisiblePercent:(CGFloat)impressionMinVisiblePercent
                       impressionMinVisibleSeconds:(NSTimeInterval)impressionMinVisibleSeconds NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly) BOOL isImpressionMinVisiblePercentValid;
@property (nonatomic, readonly) BOOL isImpressionMinVisibleSecondsValid;
@property (nonatomic, readonly) BOOL isImpressionMinVisiblePixelsValid;

/**
 `init` is not available.
 */
- (instancetype)init __attribute__((unavailable("init not available")));

@end
