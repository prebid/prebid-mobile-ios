//
//  OXAWeakTimerTargetBox.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXAWeakTimerTargetBox.h"


@interface OXAWeakTimerTargetBox ()

@property (nonatomic, weak, nullable, readonly) id weakTarget;
@property (nonatomic, nonnull, readonly) SEL aSelector;

@end



@implementation OXAWeakTimerTargetBox

- (instancetype)initWithWeakTarget:(id)weakTarget aSelector:(SEL)aSelector {
    if (!(self = [super init])) {
        return nil;
    }
    _weakTarget = weakTarget;
    _aSelector = aSelector;
    return self;
}

- (void)onTimerFired:(id<OXATimerInterface>)timer {
    const id strongTarget = self.weakTarget;
    if (strongTarget == nil) {
        [timer invalidate];
        return;
    }
    NSInvocationOperation * const operation = [[NSInvocationOperation alloc] initWithTarget:strongTarget
                                                                                   selector:self.aSelector
                                                                                     object:timer];
    if (operation) {
        [operation start];
    } else {
        [timer invalidate];
    }
}

+ (OXAScheduledTimerFactory)scheduledTimerFactoryWithWeakifiedTarget:(OXAScheduledTimerFactory)scheduledTimerFactory {
    return ^id<OXATimerInterface>(NSTimeInterval timeInterval,
                                  id aTarget,
                                  SEL aSelector,
                                  id _Nullable userInfo,
                                  BOOL repeats)
    {
        OXAWeakTimerTargetBox * const targetBox = [[OXAWeakTimerTargetBox alloc] initWithWeakTarget:aTarget
                                                                                          aSelector:aSelector];
        return scheduledTimerFactory(timeInterval,
                                     targetBox,
                                     @selector(onTimerFired:),
                                     userInfo,
                                     repeats);
    };
}

@end
