//
//  NSTimer+PBMScheduledTimerFactory.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "NSTimer+PBMTimerInterface.h"
#import "PBMScheduledTimerFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (PBMScheduledTimerFactory)

+ (PBMScheduledTimerFactory)pbmScheduledTimerFactory;

@end

NS_ASSUME_NONNULL_END
