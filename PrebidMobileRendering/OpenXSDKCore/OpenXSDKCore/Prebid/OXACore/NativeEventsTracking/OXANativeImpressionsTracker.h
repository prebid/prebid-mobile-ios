//
//  OXANativeImpressionsTracker.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeImpressionDetectionHandler.h"
#import "OXAScheduledTimerFactory.h"

@class UIView;

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeImpressionsTracker : NSObject

- (instancetype)initWithView:(UIView *)view
             pollingInterval:(NSTimeInterval)pollingInterval
       scheduledTimerFactory:(OXAScheduledTimerFactory)scheduledTimerFactory
  impressionDetectionHandler:(OXANativeImpressionDetectionHandler)impressionDetectionHandler NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
