//
//  NSTimer+OXAScheduledTimerFactory.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "NSTimer+OXATimerInterface.h"
#import "OXAScheduledTimerFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (OXAScheduledTimerFactory)

+ (OXAScheduledTimerFactory)oxaScheduledTimerFactory;

@end

NS_ASSUME_NONNULL_END
