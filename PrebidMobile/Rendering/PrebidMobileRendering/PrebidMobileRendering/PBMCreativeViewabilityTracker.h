//
//  PBMCreativeViewabilityTracker.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIView;
@class PBMAbstractCreative;
@class PBMViewExposure;
@class PBMCreativeViewabilityTracker;

typedef void(^PBMViewExposureChangeHandler)(PBMCreativeViewabilityTracker *tracker, PBMViewExposure *viewExposure);

@interface PBMCreativeViewabilityTracker : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)view pollingTimeInterval:(NSTimeInterval)pollingTimeInterval onExposureChange:(PBMViewExposureChangeHandler)onExposureChange NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCreative:(PBMAbstractCreative *)creative;

- (void)start;
- (void)stop;

/**
 Checks the current exposure.
 The onExposureChange will be called either exposure changed or isForce is true
 */
- (void)checkExposureWithForce:(BOOL)isForce;

@end

NS_ASSUME_NONNULL_END
