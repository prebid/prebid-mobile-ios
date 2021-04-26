//
//  PBMViewabilityEventDetector.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMViewabilityEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMViewabilityEventDetector : NSObject

@property (nonatomic, copy, readonly) PBMVoidBlock onEventDetected;

- (instancetype)initWithViewabilityEvents:(NSArray<PBMViewabilityEvent *> *)viewabilityEvents
                      onLastEventDetected:(nullable PBMVoidBlock)onLastEventDetected;

- (void)onExposureMeasured:(float)exposureFactor passedSinceLastMeasurement:(NSTimeInterval)deltaTime;

@end

NS_ASSUME_NONNULL_END
