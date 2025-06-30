/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
