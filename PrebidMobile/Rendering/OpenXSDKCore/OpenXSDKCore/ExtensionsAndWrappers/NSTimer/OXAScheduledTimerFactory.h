//
//  OXAScheduledTimerFactory.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXATimerInterface.h"

NS_ASSUME_NONNULL_BEGIN

typedef id<OXATimerInterface> _Nonnull (^OXAScheduledTimerFactory)(NSTimeInterval timeInterval,
                                                                   id aTarget,
                                                                   SEL aSelector,
                                                                   id _Nullable userInfo,
                                                                   BOOL repeats);

NS_ASSUME_NONNULL_END
