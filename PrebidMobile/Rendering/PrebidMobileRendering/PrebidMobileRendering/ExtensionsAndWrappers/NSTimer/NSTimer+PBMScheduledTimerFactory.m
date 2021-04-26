//
//  NSTimer+PBMScheduledTimerFactory.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "NSTimer+PBMScheduledTimerFactory.h"

@implementation NSTimer (PBMScheduledTimerFactory)

+ (PBMScheduledTimerFactory)pbmScheduledTimerFactory {
    return ^id<PBMTimerInterface>(NSTimeInterval timeInterval,
                                  id aTarget,
                                  SEL aSelector,
                                  id _Nullable userInfo,
                                  BOOL repeats)
    {
        return [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                target:aTarget
                                              selector:aSelector
                                              userInfo:userInfo
                                               repeats:repeats];
    };
}

@end
