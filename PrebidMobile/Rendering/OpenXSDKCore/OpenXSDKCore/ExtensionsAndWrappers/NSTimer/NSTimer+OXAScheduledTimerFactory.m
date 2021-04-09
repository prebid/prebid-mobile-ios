//
//  NSTimer+OXAScheduledTimerFactory.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "NSTimer+OXAScheduledTimerFactory.h"

@implementation NSTimer (OXAScheduledTimerFactory)

+ (OXAScheduledTimerFactory)oxaScheduledTimerFactory {
    return ^id<OXATimerInterface>(NSTimeInterval timeInterval,
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
