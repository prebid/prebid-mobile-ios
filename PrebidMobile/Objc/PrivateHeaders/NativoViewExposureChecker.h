#import <Foundation/Foundation.h>
#import "PBMViewExposureChecker.h"

@protocol PBMViewExposure;

NS_ASSUME_NONNULL_BEGIN

typedef void(^NativoExposureChangeHandler)(id<PBMViewExposure> exposure, NSError * _Nullable error);

/**
 Modified from PBMViewExposureChecker to support scroll based tracking instead of timer based polling
 Also fixes issue where tracking would stop during user touch
 */
@interface NativoViewExposureChecker : PBMViewExposureChecker

- (instancetype)initWithView:(UIView *)view onExposureChange:(nullable NativoExposureChangeHandler)onExposureChange;

@end

NS_ASSUME_NONNULL_END
