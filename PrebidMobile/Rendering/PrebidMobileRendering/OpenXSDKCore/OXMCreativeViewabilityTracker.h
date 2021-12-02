//
//  OXMCreativeViewabilityTracker.h
//  OpenXSDKCore
//
//  Copyright © 2019 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIView;
@class OXMAbstractCreative;
@class OXMViewExposure;
@class OXMCreativeViewabilityTracker;

typedef void(^OXMViewExposureChangeHandler)(OXMCreativeViewabilityTracker *tracker, OXMViewExposure *viewExposure);

@interface OXMCreativeViewabilityTracker : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)view pollingTimeInterval:(NSTimeInterval)pollingTimeInterval onExposureChange:(OXMViewExposureChangeHandler)onExposureChange NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCreative:(OXMAbstractCreative *)creative;

- (void)start;
- (void)stop;

/**
 Checks the current exposure.
 The onExposureChange will be called either exposure changed or isForce is true
 */
- (void)checkExposureWithForce:(BOOL)isForce;

@end

NS_ASSUME_NONNULL_END
