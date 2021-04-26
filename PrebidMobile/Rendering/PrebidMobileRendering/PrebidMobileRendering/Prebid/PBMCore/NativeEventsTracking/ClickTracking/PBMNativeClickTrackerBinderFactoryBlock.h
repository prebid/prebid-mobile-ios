//
//  PBMNativeClickTrackerBinderFactoryBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMNativeClickTrackerBinderBlock.h"

NS_ASSUME_NONNULL_BEGIN

// return 'nil' if the binder factory block is incompatible with the provided view
typedef PBMNativeClickTrackerBinderBlock _Nullable (^PBMNativeClickTrackerBinderFactoryBlock)(UIView *view);

NS_ASSUME_NONNULL_END
