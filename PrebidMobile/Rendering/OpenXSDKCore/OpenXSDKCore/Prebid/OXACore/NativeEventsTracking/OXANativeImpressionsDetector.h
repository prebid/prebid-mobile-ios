//
//  OXANativeImpressionsDetector.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeImpressionDetectionHandler.h"
#import "OXMVoidBlock.h"

@class UIView;

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeImpressionsDetector : NSObject

- (instancetype)initWithView:(UIView *)view
  impressionDetectionHandler:(OXANativeImpressionDetectionHandler)impressionDetectionHandler
    onLastImpressionDetected:(OXMVoidBlock)onLastImpressionDetected NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)checkViewabilityWithTimeSinceLastCheck:(NSTimeInterval)timeSinceLastCheck;

@end

NS_ASSUME_NONNULL_END
