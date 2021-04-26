//
//  PBMNativeImpressionsTracker.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeImpressionDetectionHandler.h"
#import "PBMScheduledTimerFactory.h"

@class UIView;

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeImpressionsTracker : NSObject

- (instancetype)initWithView:(UIView *)view
             pollingInterval:(NSTimeInterval)pollingInterval
       scheduledTimerFactory:(PBMScheduledTimerFactory)scheduledTimerFactory
  impressionDetectionHandler:(PBMNativeImpressionDetectionHandler)impressionDetectionHandler NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
