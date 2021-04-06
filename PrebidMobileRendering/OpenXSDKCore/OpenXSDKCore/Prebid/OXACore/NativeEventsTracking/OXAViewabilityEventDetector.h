//
//  OXAViewabilityEventDetector.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAViewabilityEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAViewabilityEventDetector : NSObject

@property (nonatomic, copy, readonly) OXMVoidBlock onEventDetected;

- (instancetype)initWithViewabilityEvents:(NSArray<OXAViewabilityEvent *> *)viewabilityEvents
                      onLastEventDetected:(nullable OXMVoidBlock)onLastEventDetected;

- (void)onExposureMeasured:(float)exposureFactor passedSinceLastMeasurement:(NSTimeInterval)deltaTime;

@end

NS_ASSUME_NONNULL_END
