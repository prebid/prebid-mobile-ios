//
//  OXANativeClickTrackerBinderBlock.h
//  OpenXSDKCore
//
//  Copyright © 2021 OpenX. All rights reserved.
//

#import "OXMVoidBlock.h"

@class UIView;

NS_ASSUME_NONNULL_BEGIN

typedef OXMVoidBlock _Nonnull (^OXANativeClickTrackerBinderBlock)(OXMVoidBlock onClickBlock); /// returns 'detachment' block

NS_ASSUME_NONNULL_END
