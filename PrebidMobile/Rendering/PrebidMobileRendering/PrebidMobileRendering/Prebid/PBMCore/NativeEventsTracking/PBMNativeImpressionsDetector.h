//
//  PBMNativeImpressionsDetector.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeImpressionDetectionHandler.h"
#import "PBMVoidBlock.h"

@class UIView;

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeImpressionsDetector : NSObject

- (instancetype)initWithView:(UIView *)view
  impressionDetectionHandler:(PBMNativeImpressionDetectionHandler)impressionDetectionHandler
    onLastImpressionDetected:(PBMVoidBlock)onLastImpressionDetected NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)checkViewabilityWithTimeSinceLastCheck:(NSTimeInterval)timeSinceLastCheck;

@end

NS_ASSUME_NONNULL_END
