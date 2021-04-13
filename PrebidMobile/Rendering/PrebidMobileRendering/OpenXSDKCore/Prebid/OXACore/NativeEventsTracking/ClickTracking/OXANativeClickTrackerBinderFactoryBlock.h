//
//  OXANativeClickTrackerBinderFactoryBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXANativeClickTrackerBinderBlock.h"

NS_ASSUME_NONNULL_BEGIN

// return 'nil' if the binder factory block is incompatible with the provided view
typedef OXANativeClickTrackerBinderBlock _Nullable (^OXANativeClickTrackerBinderFactoryBlock)(UIView *view);

NS_ASSUME_NONNULL_END
