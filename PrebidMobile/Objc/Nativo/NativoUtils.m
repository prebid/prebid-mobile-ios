//
//  NativoUtils.m
//  NativoPrebidSDK
//
//  Created by Matthew Murray on 12/11/25.
//

#import "NativoUtils.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NativoUtils

+ (Debouncable)debounceAction:(void (^)(id param))action withInterval:(NSTimeInterval)interval {
    __block BOOL shouldFire = YES;
    int64_t dispatchDelay = (int64_t)(interval * NSEC_PER_SEC);
    return ^(id param) {
        if (shouldFire) {
            shouldFire = NO;
            action(param);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, dispatchDelay), dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
                shouldFire = YES;
            });
        }
    };
}

@end

NS_ASSUME_NONNULL_END
