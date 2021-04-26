//
//  PBMWeakTimerTargetBox.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMTimerInterface.h"
#import "PBMScheduledTimerFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMWeakTimerTargetBox : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (PBMScheduledTimerFactory)scheduledTimerFactoryWithWeakifiedTarget:(PBMScheduledTimerFactory)scheduledTimerFactory;

@end

NS_ASSUME_NONNULL_END
