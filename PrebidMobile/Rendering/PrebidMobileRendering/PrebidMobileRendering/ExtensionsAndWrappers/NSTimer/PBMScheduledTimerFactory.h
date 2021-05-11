//
//  PBMScheduledTimerFactory.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//


#import "PBMTimerInterface.h"

NS_ASSUME_NONNULL_BEGIN

typedef id<PBMTimerInterface> _Nonnull (^PBMScheduledTimerFactory)(NSTimeInterval timeInterval,
                                                                   id aTarget,
                                                                   SEL aSelector,
                                                                   id _Nullable userInfo,
                                                                   BOOL repeats);

NS_ASSUME_NONNULL_END
