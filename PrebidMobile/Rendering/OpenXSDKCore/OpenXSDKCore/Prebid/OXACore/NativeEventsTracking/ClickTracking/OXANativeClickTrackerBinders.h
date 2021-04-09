//
//  OXANativeClickTrackerBinders.h
//  OpenXApolloSDK
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeClickTrackerBinderFactoryBlock.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeClickTrackerBinders : NSObject

@property (nonatomic, class, nonnull, readonly) OXANativeClickTrackerBinderFactoryBlock smartBinder;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
