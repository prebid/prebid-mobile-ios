//
//  PBMWeakTimerTargetBox.m
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMWeakTimerTargetBox.h"


@interface PBMWeakTimerTargetBox ()

@property (nonatomic, weak, nullable, readonly) id weakTarget;
@property (nonatomic, nonnull, readonly) SEL aSelector;

@end



@implementation PBMWeakTimerTargetBox

- (instancetype)initWithWeakTarget:(id)weakTarget aSelector:(SEL)aSelector {
    if (!(self = [super init])) {
        return nil;
    }
    _weakTarget = weakTarget;
    _aSelector = aSelector;
    return self;
}

- (void)onTimerFired:(id<PBMTimerInterface>)timer {
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

+ (PBMScheduledTimerFactory)scheduledTimerFactoryWithWeakifiedTarget:(PBMScheduledTimerFactory)scheduledTimerFactory {
    return ^id<PBMTimerInterface>(NSTimeInterval timeInterval,
                                  id aTarget,
                                  SEL aSelector,
                                  id _Nullable userInfo,
                                  BOOL repeats)
    {
        PBMWeakTimerTargetBox * const targetBox = [[PBMWeakTimerTargetBox alloc] initWithWeakTarget:aTarget
                                                                                          aSelector:aSelector];
        return scheduledTimerFactory(timeInterval,
                                     targetBox,
                                     @selector(onTimerFired:),
                                     userInfo,
                                     repeats);
    };
}

@end
