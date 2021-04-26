//
//  PBMNativeClickTrackerBinders.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeClickTrackerBinderFactoryBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeClickTrackerBinders : NSObject

@property (nonatomic, class, nonnull, readonly) PBMNativeClickTrackerBinderFactoryBlock smartBinder;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
