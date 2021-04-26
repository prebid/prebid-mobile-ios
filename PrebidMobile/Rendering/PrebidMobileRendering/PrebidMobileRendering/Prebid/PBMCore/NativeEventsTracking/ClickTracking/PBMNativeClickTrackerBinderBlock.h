//
//  PBMNativeClickTrackerBinderBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "PBMVoidBlock.h"

@class UIView;

NS_ASSUME_NONNULL_BEGIN

typedef PBMVoidBlock _Nonnull (^PBMNativeClickTrackerBinderBlock)(PBMVoidBlock onClickBlock); /// returns 'detachment' block

NS_ASSUME_NONNULL_END
