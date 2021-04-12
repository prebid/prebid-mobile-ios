//
//  OXAWeakTimerTargetBox.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXATimerInterface.h"
#import "OXAScheduledTimerFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXAWeakTimerTargetBox : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (OXAScheduledTimerFactory)scheduledTimerFactoryWithWeakifiedTarget:(OXAScheduledTimerFactory)scheduledTimerFactory;

@end

NS_ASSUME_NONNULL_END
